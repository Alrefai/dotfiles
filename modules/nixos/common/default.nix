# Common NixOS configuration shared across all hosts
{ ... }:
{
  imports = [
    ./nix.nix
    ./users.nix
    ./packages.nix
    ./services.nix
  ];

  # Limit the number of generations to keep
  boot.loader.systemd-boot.configurationLimit = 5;
}