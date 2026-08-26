{
  lib, # My own lib; use `pkgs.lib` for upstream
  pkgs,
  wrappers,
  ...
}: let
  catppuccin = pkgs.catppuccinSources.bat + "/Catppuccin Mocha.tmTheme";

  replacements = import ../themes/catppuccin-mocha-oled.nix {inherit lib pkgs;};

  oledTheme = pkgs.runCommand "bat-catppuccin-mocha-oled" {} ''
    substitute "${catppuccin}" "$out" \
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
        path = oledTheme;
      }
    ]);
  });
in
  bat.wrapper
