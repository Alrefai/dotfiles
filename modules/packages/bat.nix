{
  lib, # My own lib; use `pkgs.lib` for upstream
  pkgs,
  wrappers,
  ...
}: let
  catppuccin = pkgs.catppuccin.override {
    variant = "mocha";
    themeList = ["bat"];
  };

  replacements = [
    ["#1e1e2e" "#000000"]
    ["#181825" "#010101"]
    ["#11111b" "#020202"]
  ];

  oledTheme = pkgs.runCommand "catppuccin-mocha-oled" {} ''
    substitute "${catppuccin}/bat/Catppuccin Mocha.tmTheme" "$out" \
      ${lib.substituteReplacements {inherit replacements;}}
  '';

  bat = wrappers.wrapperModules.bat.apply ({config, ...}: {
    inherit pkgs;

    bat-config.content = ''
      --italic-text=always
      --style=full
      --theme='Catppuccin Mocha'
    '';

    env.BAT_CONFIG_DIR = toString (config.pkgs.linkFarm "bat-config-dir" [
      {
        name = "config";
        inherit (config.bat-config) path;
      }
      {
        name = "themes/Catppuccin Mocha.tmTheme";
        path = "${oledTheme}";
      }
    ]);
  });
in
  bat.wrapper
