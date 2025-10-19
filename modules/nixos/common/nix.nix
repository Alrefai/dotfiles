# Nix daemon configuration, cachix, and experimental features
{pkgs, ...}: let
  shared = import ../../../shared/nix.nix;
in {
  nix = {
    package = pkgs.lixPackageSets.stable.lix;
    settings = shared.commonSettings // {
      auto-optimise-store = true;
      # NixOS specific caches
      extra-substituters = ["https://midot.cachix.org"];
      extra-trusted-substituters = ["https://cache.flakehub.com"];
      extra-trusted-public-keys = shared.commonSettings.extra-trusted-public-keys ++ [
        "midot.cachix.org-1:QOnnEfGYhNLcqLKOXBNutkKqHpDU3nuNyZBGgeNZXJI="
      ];
      trusted-users = ["@admin" "@wheel"];
    };
  };
}
