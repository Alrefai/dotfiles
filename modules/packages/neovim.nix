{
  minvim,
  pkgs,
  wrappers,
  ...
}:
wrappers.lib.wrapPackage {
  inherit pkgs;
  package = pkgs.neovim;
  runtimeInputs =
    pkgs.lib.attrValues {
      inherit
        (pkgs)
        curl
        fd
        gcc
        gitMinimal
        gnumake
        marksman
        nixd
        nodejs_latest
        ripgrep
        unzip
        wget
        ;
      inherit (pkgs.luaPackages) tree-sitter-cli;
    }
    ++ pkgs.lib.attrValues pkgs.devTools;
  env = let
    name = "minvim-wrapper";
  in {
    NVIM_APPNAME = name;
    XDG_CONFIG_HOME = toString (pkgs.linkFarm "neovim-config-dir" [
      {
        inherit name;
        path = minvim;
      }
    ]);
  };
}
