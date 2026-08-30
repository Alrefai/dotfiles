{
  pkgs,
  wrappers,
  ...
}: let
  inherit
    (pkgs.lib)
    mkDefault
    mkOption
    optionalAttrs
    types
    ;

  module = wrappers.lib.wrapModule ({
    config,
    wlib,
    ...
  }: let
    yamlFormat = config.pkgs.formats.yaml {};
  in {
    /**
    Options were partially taken from home-manager eza module
    */
    options = {
      icons = mkOption {
        type = types.enum [
          null
          "auto"
          "always"
          "never"
        ];
        default = null;
        description = ''
          Display icons next to file names (`--icons` argument).
        '';
      };

      colors = mkOption {
        type = types.enum [
          null
          "auto"
          "always"
          "never"
        ];
        default = null;
        description = ''
          Use terminal colors in output (`--color` argument).
        '';
      };

      git = mkOption {
        type = types.bool;
        default = false;
        description = ''
          List each file's Git status if tracked or ignored
          (`--git` argument).
        '';
      };

      theme = mkOption {
        inherit (yamlFormat) type;
        default = {};
        description = ''
          Written to `theme.yml`

          See <https://github.com/eza-community/eza#custom-themes>
        '';
      };

      themeFile = mkOption {
        type = wlib.types.file config.pkgs;
        default.path = toString (yamlFormat.generate "theme.yaml" config.theme);
        description = "eza theme file (`theme.yaml`).";
      };
    };

    config = {
      package = mkDefault config.pkgs.eza;
      env.EZA_CONFIG_DIR = mkDefault (toString (
        config.pkgs.linkFarm "eza-config-dir" {
          "theme.yaml" = config.themeFile.path;
        }
      ));
      flags =
        optionalAttrs (config.icons != null) {"--icons" = config.icons;}
        // optionalAttrs (config.colors != null) {"--color" = config.colors;}
        // optionalAttrs config.git {"--git" = true;};
    };
  });

  eza = module.apply {
    inherit pkgs;
    colors = "auto";
    git = true;
    flags = {
      "--git-repos" = true;
      "--group-directories-first" = true;
      "--header" = true;
    };
    icons = "auto";
    themeFile.path = pkgs.catppuccinSources
      .eza + "/mocha/catppuccin-mocha-blue.yml";
  };
in
  eza.wrapper
