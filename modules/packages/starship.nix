{
  pkgs,
  wrappers,
  ...
}: let
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
      // pkgs.lib.importTOML (pkgs.catppuccinSources.starship + "/mocha.toml");
  };
in
  starship.wrapper
