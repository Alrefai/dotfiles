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
    # Service credentials are acquired at the moment of service activation, and
    # released on service deactivation. They are immutable during the service
    # runtime.
    #
    # ---
    # refs:
    # - https://systemd.io/CREDENTIALS/
    LoadCredential = ["croc-pass:/persistent/secrets/croc/pass"];
    # %d resolves to the service’s credential directory.
    Environment = "CROC_PASS=%d/croc-pass";

    ExecStart = lib.mkForce ''
      ${lib.getExe pkgs.croc} ${withDebug} \
        relay --port ${port} --ports ${ports} --transfers ${numberOfPorts}
    '';
  };
}
