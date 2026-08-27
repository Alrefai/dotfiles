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
    zsh.enable = lib.mkDefault true;
  };

  environment = {
    systemPackages = map lib.lowPrio (builtins.attrValues {
      inherit
        (pkgs)
        curl
        gitMinimal
        ;
      inherit (pkgs.ghostty) terminfo;
      inherit (pkgs.wrappers) bottom neovim;
    });
    variables.EDITOR = "nvim";
  };
}
