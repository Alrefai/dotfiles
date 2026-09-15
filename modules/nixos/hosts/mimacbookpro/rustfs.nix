{
  config,
  dataDisksMountpointSuffix,
  pkgs,
  username,
  ...
}: let
  inherit
    (pkgs.lib)
    concatStringsSep
    filterAttrs
    genAttrs
    getExe
    hasPrefix
    length
    lessThan
    mapAttrsToList
    mkForce
    mkIf
    pipe
    sort
    ;

  isDataDisk = key: _: hasPrefix dataDisksMountpointSuffix key;

  mountpoint = _: disk: disk.content.content.mountpoint;

  dataMountpoints = pipe config.disko.devices.disk [
    (filterAttrs isDataDisk)
    (mapAttrsToList mountpoint)
    (sort lessThan)
  ];

  dataDisksCount = length dataMountpoints;

  rule = _: {
    d = {
      group = config.users.users.rustfs.group;
      mode = "0750";
      user = config.users.users.rustfs.name;
    };
  };

  systemdTmpfilesRules = genAttrs dataMountpoints rule;
in {
  assertions = [
    {
      assertion = dataMountpoints != [];
      message = "RustFS requires at least one data disk.";
    }
  ];

  users.users.${username}.extraGroups = ["rustfs"];

  services = {
    rustfs = {
      enable = true;
      environmentFile = mkForce "";
      settings = {
        RUSTFS_STORAGE_CLASS_RRS = mkIf (dataDisksCount > 1) "EC:1";
        RUSTFS_STORAGE_CLASS_STANDARD = mkIf (dataDisksCount > 1) "EC:1";
        RUSTFS_VOLUMES = concatStringsSep " " dataMountpoints;
        RUSTFS_KMS_ENABLE = "true";
        RUSTFS_KMS_BACKEND = "vault-transit";
        RUSTFS_KMS_VAULT_MOUNT_PATH = "rustfs";
        RUSTFS_KMS_VAULT_TRANSIT_METADATA_KV_MOUNT = "rustfs-kv";
        RUSTFS_KMS_DEFAULT_KEY_ID = "rustfs-default-key";
      };
    };
  };

  systemd = let
    /**
    RustFS root credentials via environment variables and encrypted secret files
    are for initial setup and break-glass administration. The root account
    bypasses policy checks (owner semantics).

    NOTE: Key Login uses the access key and secret key configured for the RustFS
    deployment. This is the standard login method for a local administrator.
    */
    rustfs-encrypted-access-key = ''
      rustfs-access-key: \
        Whxqht+dQJax1aZeCGLxmiAAAAABAAAADAAAABAAAABDWcaGwXNJTTcnESUAAAAAI1RWQ \
        73rKRjXtVTV89KHU7wCthZqzyFKqsMDIGQht59Ev2+6lAeA71wCffw/QVOfFTCNf4pAqT \
        pUWhjgBWDxTqVLDbkBX9rFaHRfO18iAOSKKKkuRFMb8y3eoIXTFN5KnewSpxaym5ieTXp \
        JbpubTkoCABAtHWM1vg==
    '';
    rustfs-encrypted-secret-key = ''
      rustfs-secret-key: \
        Whxqht+dQJax1aZeCGLxmiAAAAABAAAADAAAABAAAABDelk4lDLLEpjOs9sAAAAAdktnC \
        xC0+mleAIEd8ZWU+ikK2+sTZQHOvh6hfffRyV4lBbaLxnc6LBk5sa2UWUSqtPqBZ9p6Mj \
        1FV2tVdT58ZLfFMEkVIxnhGiqGM7AMvk8HvMyvro/ZLvntSan1jPTc/+VJCpq041ReCqr \
        OZbKflMxspxnaLRYisg==
    '';
    rustfs-kms-vault-encrypted-token = ''
      rustfs-kms-vault-token: \
        Whxqht+dQJax1aZeCGLxmiAAAAABAAAADAAAABAAAACVtxNmMpiLv+lhoGcAAAAAp5wmF \
        owVs9XE0qHh+5/5ixucS7RKn/IDHRoB/5mSVE9p4viWhRGJUvHYCdcfGCk3dCqgxejcPS \
        nEaD1+YJ8aRkn5Zl9c9itxZomFnuzgsVbAJexopUaZrDysEVhqG2XlZShTd1Zxvmh9Jpx \
        +Td+5Rq0nB1U2AMgn7BgOhw2w4Ai/oiG1t4CrjpXnZxC3151DuJQLxQPoAjTavDH6B2fi \
        /w==
    '';
    kms-vault-encrypted-address = ''
      kms-vault-address: \
        Whxqht+dQJax1aZeCGLxmiAAAAABAAAADAAAABAAAACsCLviLIuOmfvrVBIAAAAAukmRw \
        d9Y5iWB1OjeGce628nyrLN2/vSM9JHr9tYeoOa1O6s/mIB0FEcMgWBVySo6BMCSPpQiMZ \
        5qaYrLI3+xRYxW7jmw6L2yPyiTBa6nokRowx0IxSKffg==
    '';

    rustfs-wrapper = pkgs.writeShellScript "rustfs-wrapper" ''
      TOKEN_FILE='rustfs-kms-vault-token'

      install -m 0400 \
        "$CREDENTIALS_DIRECTORY/$TOKEN_FILE" \
        "$RUNTIME_DIRECTORY/$TOKEN_FILE"

      read -r RUSTFS_KMS_VAULT_ADDRESS \
        <"$CREDENTIALS_DIRECTORY/kms-vault-address"

      export RUSTFS_KMS_VAULT_ADDRESS
      export RUSTFS_KMS_VAULT_TOKEN_FILE="$RUNTIME_DIRECTORY/$TOKEN_FILE"

      exec ${getExe config.services.rustfs.package}
    '';
  in {
    services = {
      rustfs = {
        preStart = mkForce "";
        serviceConfig = {
          RuntimeDirectory = "rustfs";
          SetCredentialEncrypted = [
            rustfs-encrypted-access-key
            rustfs-encrypted-secret-key
            rustfs-kms-vault-encrypted-token
            kms-vault-encrypted-address
          ];
          ExecStart = mkForce rustfs-wrapper;
        };
        environment = {
          RUSTFS_ACCESS_KEY_FILE = "%d/rustfs-access-key";
          RUSTFS_SECRET_KEY_FILE = "%d/rustfs-secret-key";
        };
        unitConfig.RequiresMountsFor = dataMountpoints;
      };

      tailscale-serve-rustfs = {
        description = "Serve RustFS Console and S3 Endpoints with Tailscale";

        after = [
          "tailscaled-autoconnect.service"
          "tailscaled-set.service"
          "tailscale-serve.service"
        ];
        requires = ["tailscaled.service" "rustfs.service"];
        wantedBy = ["multi-user.target"];

        serviceConfig = {
          Type = "oneshot";
          ExecStart = [
            ''
              ${getExe config.services.tailscale.package} serve \
                --service=svc:rustfs --https=443 9001
            ''
            ''
              ${getExe config.services.tailscale.package} serve \
                --service=svc:s3 --https=443 9000
            ''
          ];
        };
      };
    };

    tmpfiles.settings."10-rustfs" = mkForce systemdTmpfilesRules;
  };
}
