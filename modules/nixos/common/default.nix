# Common NixOS configuration shared across all hosts and VMs
{
  config,
  lib,
  overlays,
  pkgs,
  system,
  ...
}: {
  imports = [
    ./packages.nix
    ./tailscale.nix
    ./users.nix
    ./virtualisation.nix
  ];

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  networking.resolvconf.enable = lib.mkIf config.services.tailscale
    .enable false;

  nixpkgs = {
    inherit overlays;
    hostPlatform = system;
  };

  # Set your time zone.
  time.timeZone = "Asia/Riyadh";
}
