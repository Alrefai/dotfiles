{
  config,
  pkgs,
  ...
}: let
  port = 8200;
in {
  environment.systemPackages = [pkgs.vault];

  services = let
    address = "127.0.0.1";
  in {
    vault = {
      enable = true;
      address = "${address}:${toString port}";
      extraConfig = ''
        api_addr = "http://${address}:${toString port}"
        cluster_addr = "http://${address}:${toString (port + 1)}"
        disable_mlock = true
      '';
      storageBackend = "raft";
      storageConfig = ''
        node_id = "vault01"
      '';
      storagePath = "/persistent/var/lib/vault";
    };
  };

  systemd.services.tailscale-serve-vault = {
    description = "Serve Vault endpoint with Tailscale";

    after = [
      "tailscaled-autoconnect.service"
      "tailscaled-set.service"
      "tailscale-serve.service"
    ];
    requires = ["tailscaled.service" "vault.service"];
    wantedBy = ["multi-user.target"];

    serviceConfig = {
      Type = "oneshot";
      ExecStart = [
        ''
          ${pkgs.lib.getExe config.services.tailscale.package} serve \
            --service=svc:vault --https=443 ${toString port}
        ''
      ];
    };
  };
}
