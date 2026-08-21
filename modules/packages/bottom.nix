{
  lib, # My own lib; use `pkgs.lib` for upstream
  pkgs,
  wrappers,
  ...
}: let
  inherit (pkgs.lib) importTOML mkDefault mkOption;

  catppuccin = pkgs.catppuccinSources.bottom;

  replacements = import ../themes/catppuccin-mocha-oled.nix {inherit lib pkgs;};

  oledTheme = pkgs.runCommand "bottom-catppuccin-mocha-oled" {} ''
    substitute "${catppuccin}/themes/mocha.toml" "$out" \
      ${lib.substituteReplacements {inherit replacements;}}
  '';

  module = wrappers.lib.wrapModule ({
    config,
    wlib,
    ...
  }: let
    tomlFormat = config.pkgs.formats.toml {};
  in {
    /**
    Options were partially taken from home-manager bottom module
    */
    options = {
      settings = mkOption {
        inherit (tomlFormat) type;
        default = {};
        description = ''
          Configuration written to `bottom.toml`.

          ---
          See:
          https://clementtsang.github.io/bottom/stable/configuration/config-file
        '';
        example = {
          flags = {
            avg_cpu = true;
            temperature_type = "c";
          };
          colors = {
            low_battery_color = "red";
          };
        };
      };

      configFile = mkOption {
        type = wlib.types.file config.pkgs;
        default.path = toString (
          tomlFormat.generate "bottom.toml" config.settings
        );
        description = "bottom configuration file.";
      };
    };

    config = {
      package = mkDefault config.pkgs.bottom;
      flags = {"--config_location" = config.configFile.path;};
    };
  });

  bottom = module.apply {
    inherit pkgs;
    settings =
      {
        flags = {show_table_scroll_position = true;};
        memory_graph = {cache_memory = true;};
        network_graph = {use_bytes = true;};
        temperature = {
          default_sort = "Temp";
          sort_order = "Descending";
        };
      }
      // importTOML "${oledTheme}";
  };
in
  bottom.wrapper
