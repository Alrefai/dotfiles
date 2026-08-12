# Common system packages and programs
{
  lib,
  pkgs,
  ...
}: {
  programs = {
    nix-ld = {
      enable = true;
      libraries = [pkgs.glibc];
    };
    zsh.enable = true;
  };

  environment = {
    systemPackages = map lib.lowPrio (builtins.attrValues {
      inherit
        (pkgs)
        curl
        gitMinimal
        neovim
        ;
      inherit (pkgs.ghostty) terminfo;
    });
    variables.EDITOR = "nvim";
  };
}
