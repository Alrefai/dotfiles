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
}
