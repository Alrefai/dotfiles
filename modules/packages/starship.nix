{
  lib, # My own lib; use `pkgs.lib` for upstream
  pkgs,
  wrappers,
  ...
}: let
  catppuccin = pkgs.catppuccin.override {
    variant = "mocha";
    themeList = ["starship"];
  };

  replacements = import ../themes/catppuccin-mocha-oled.nix {inherit lib pkgs;};

  oledTheme = pkgs.runCommand "starship-catppuccin-mocha-oled" {} ''
    substitute "${catppuccin}/starship/mocha.toml" "$out" \
      ${lib.substituteReplacements {inherit replacements;}}
  '';

  starship = wrappers.wrapperModules.starship.apply {
    inherit pkgs;
    settings =
      {
        "$schema" = "https://starship.rs/config-schema.json";
        command_timeout = 3000;
        container = {disabled = true;};
        git_branch = {symbol = " ";};
        hostname = {ssh_symbol = " ";};
        os = {
          disabled = false;
          symbols = {
            Arch = " ";
            Macos = "";
            NixOS = " ";
            Ubuntu = " ";
          };
        };
        shell = {
          disabled = false;
          format = "[$indicator]($style)";
          bash_indicator = " ";
          zsh_indicator = "";
        };
      }
      // pkgs.lib.importTOML "${oledTheme}";
  };
in
  starship.wrapper
