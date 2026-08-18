{pkgs, ...}: let
  inherit
    (pkgs.lib)
    readFile
    pipe
    fromJSON
    getAttrFromPath
    mapAttrs
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
in [
  [mocha.base oled.mocha.base]
  [mocha.mantle oled.mocha.mantle]
  [mocha.crust oled.mocha.crust]
]
