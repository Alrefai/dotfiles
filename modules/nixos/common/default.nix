# Common NixOS configuration shared across all hosts
_: {
  imports = [
    ../../common
    ./users.nix
    ./packages.nix
    ./services.nix
  ];

  nix = {
    channel.enable = false;
    optimise.automatic = true;
  };

  # Limit the number of generations to keep
  boot.loader.systemd-boot.configurationLimit = 5;
}
