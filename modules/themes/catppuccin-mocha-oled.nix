{
  lib, # My own lib; use `pkgs.lib` for upstream
  pkgs,
  ...
}: let
  inherit
    (pkgs.lib)
    getAttrFromPath
    importJSON
    mapAttrs
    pipe
    ;

  mocha = pipe "${pkgs.catppuccinSources.palette}/palette.json" [
    importJSON
    (getAttrFromPath ["mocha" "colors"])
    (mapAttrs (_: {hex, ...}: hex))
  ];

  oled.mocha = {
    base = "#000000";
    mantle = "#010101";
    crust = "#020202";
  };
in
  lib.mkReplacements mocha oled.mocha
