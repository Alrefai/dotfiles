# Nix daemon configuration, cachix, and experimental features
{pkgs, ...}: {
  nix = {
    package = pkgs.lixPackageSets.stable.lix;
    settings = {
      auto-optimise-store = true;
      experimental-features = ["nix-command" "flakes"];
      extra-substituters = ["https://midot.cachix.org"];
      extra-trusted-public-keys = [
        "midot.cachix.org-1:QOnnEfGYhNLcqLKOXBNutkKqHpDU3nuNyZBGgeNZXJI="
      ];
      trusted-users = ["@admin" "@wheel"];
      use-xdg-base-directories = true;
    };
  };
}
