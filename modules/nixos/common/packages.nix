# Common system packages and programs
{ pkgs, ... }:
{
  programs.nix-ld = {
    enable = true;
    package = pkgs.nix-ld-rs;
    libraries = [pkgs.glibc];
  };

  # Common development tools
  environment.systemPackages = [
    pkgs.podman-compose
  ];
}
