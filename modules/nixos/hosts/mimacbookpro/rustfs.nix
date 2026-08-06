{
  config,
  dataDisksMountpointSuffix,
  lib,
  username,
  ...
}: let
  isDataDisk = key: _: lib.hasPrefix dataDisksMountpointSuffix key;

  mountpoint = _: disk: disk.content.content.mountpoint;

  dataMountpoints = lib.pipe config.disko.devices.disk [
    (lib.filterAttrs isDataDisk)
    (lib.mapAttrsToList mountpoint)
    (builtins.sort builtins.lessThan)
  ];

  dataDisksCount = builtins.length dataMountpoints;

  rule = _: {
    d = {
      group = config.users.users.rustfs.group;
      mode = "0750";
      user = config.users.users.rustfs.name;
    };
  };

  systemdTmpfilesRules = lib.genAttrs dataMountpoints rule;
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
      environmentFile = lib.mkForce "";
      settings = {
        RUSTFS_STORAGE_CLASS_RRS = lib.mkIf (dataDisksCount > 1) "EC:1";
        RUSTFS_STORAGE_CLASS_STANDARD = lib.mkIf (dataDisksCount > 1) "EC:1";
        RUSTFS_VOLUMES = builtins.concatStringsSep " " dataMountpoints;
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
  in {
    services = {
      rustfs = {
        preStart = lib.mkForce "";
        serviceConfig = {
          SetCredentialEncrypted = [
            rustfs-encrypted-access-key
            rustfs-encrypted-secret-key
          ];
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
              ${lib.getExe config.services.tailscale.package} serve \
                --service=svc:rustfs --https=443 9001
            ''
            ''
              ${lib.getExe config.services.tailscale.package} serve \
                --service=svc:s3 --https=443 9000
            ''
          ];
        };
      };
    };

    tmpfiles.settings."10-rustfs" = lib.mkForce systemdTmpfilesRules;
  };
}
