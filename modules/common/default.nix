{
  lib,
  pkgs,
  ...
}: {
  # Configure Nix
  nix = {
    gc = {
      automatic = true;
      options = "--delete-older-than 7d";
    };
    package = pkgs.lixPackageSets.stable.lix;
    settings = {
      # Disable auto-optimise-store because of this issue in darwin:
      # https://github.com/NixOS/nix/issues/7273
      # "error: cannot link '/nix/store/.tmp-link-xxxxx-xxxxx'
      # to '/nix/store/.links/xxxx': File exists"
      auto-optimise-store = false;
      builders-use-substitutes = true;
      experimental-features = ["nix-command" "flakes"];
      substituters = [
        (lib.mkIf pkgs.stdenv.isDarwin "https://nix-community.cachix.org")
        "https://midot.cachix.org"
        "https://cache.nixos.org"
        "https://cache.lix.systems"
      ];
      trusted-public-keys = [
        (lib.mkIf pkgs.stdenv.isDarwin "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=")
        "midot.cachix.org-1:QOnnEfGYhNLcqLKOXBNutkKqHpDU3nuNyZBGgeNZXJI="
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "cache.lix.systems:aBnZUw8zA7H35Cz2RyKFVs3H4PlGTLawyY5KRbvJR8o="
      ];
      trusted-users = ["@admin" "@wheel"];
      use-xdg-base-directories = true;
    };
  };
}
