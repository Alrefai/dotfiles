{
  lib, # My own lib; use `pkgs.lib` for upstream
  pkgs,
  ...
}: let
  inherit
    (pkgs.lib)
    fromJSON
    getAttrFromPath
    mapAttrs
    pipe
    readFile
    ;

  catppuccin = pkgs.catppuccin.override {themeList = ["palette"];};

  mocha = pipe "${catppuccin}/palette/palette.json" [
    readFile
    fromJSON
    (getAttrFromPath ["mocha" "colors"])
    (mapAttrs (_: {hex, ...}: hex))
  ];

  oled.mocha = {
    base = "000000";
    mantle = "010101";
    crust = "020202";
  };
in
  lib.mkReplacements mocha oled.mocha
