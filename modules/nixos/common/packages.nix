# Common system packages and programs
{pkgs, ...}: {
  programs.nix-ld = {
    enable = true;
    libraries = [pkgs.glibc];
  };

  # Common development tools
  environment.systemPackages = [
    pkgs.podman-compose
  ];
}
