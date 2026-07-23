{
  config,
  lib,
  pkgs,
  ...
}: let
  port = toString (builtins.head config.services.croc.ports or 9009);
in {
  environment.systemPackages = [pkgs.croc];

  services = {
    croc = {
      enable = true;
      # debug = true;
      # openFirewall = true;
      pass = "/persistent/secrets/croc/pass";
      ports = [
        39816
        39817
        39818
        39819
        39820
      ];
    };

    tailscale.serve.services.croc.endpoints = {
      "tcp:443" = "tcp://127.0.0.1:${port}";
    };
  };

  systemd.services.croc.serviceConfig = let
    numberOfPorts = toString (builtins.length config.services.croc.ports or 5);
    ports = lib.concatMapStringsSep "," toString config.services.croc.ports;
    withDebug = lib.optionalString config.services.croc.debug "--debug";
  in {
    LoadCredential = ["croc-pass:${config.services.croc.pass}"];

    ExecStart = lib.mkForce (
      pkgs.writeShellScript "croc-relay" ''
        read -r PASS < "$CREDENTIALS_DIRECTORY/croc-pass"

        exec env CROC_PASS="$PASS" ${lib.getExe pkgs.croc} ${withDebug} \
          relay --port ${port} --ports ${ports} --transfers ${numberOfPorts}
      ''
    );
  };
}
