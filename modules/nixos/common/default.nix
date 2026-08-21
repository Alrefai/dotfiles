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

  /**
  Override the default Nix profiles and their order in PATH.

  When `use-xdg-base-directories` is enabled, use the Home Manager profile under
  `XDG_STATE_HOME` and remove obsolete profile entries from `NIX_PROFILES`.

  This also fixes in Darwin:
  - Stand-alone Home Manager installation.
  - `~/.nix-profile` being used.
  - Multiple versions of Nix being found in PATH.

  NOTE: `use-xdg-base-directories` must be set to `true` in `/etc/nix/nix.conf`.

  */
  environment.profiles = lib.mkIf config.nix.settings.use-xdg-base-directories (
    lib.mkForce [
      "$HOME/.local/state/nix/profile" # home manager nix profile
      "/run/current-system/sw" # nixos and darwin nix profile
    ]
  );

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
