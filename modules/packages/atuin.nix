{
  pkgs,
  wrappers,
  ...
}: let
  inherit
    (pkgs.lib)
    attrValues
    elem
    hasAttrByPath
    literalExpression
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
    tomlFormat = config.pkgs.formats.toml {};
  in {
    /**
    Options were partially taken from home-manager atuin module
    */
    options = {
      settings = mkOption {
        type = let
          prim = types.oneOf (attrValues {inherit (types) bool int str;});
          primOrPrimAttrs = types.either prim (types.attrsOf prim);
          entry = types.either prim (types.listOf primOrPrimAttrs);
          entryOrAttrsOf = t: types.either entry (types.attrsOf t);
          entries = entryOrAttrsOf (entryOrAttrsOf entry);
        in
          types.attrsOf entries // {description = "Atuin configuration";};
        default = {};
        example = literalExpression ''
          {
            auto_sync = true;
            sync_frequency = "5m";
            sync_address = "https://api.atuin.sh";
            search_mode = "prefix";
          }
        '';
        description = ''
          Configuration written to `ATUIN_CONFIG_DIR/config.toml`.

          ---

          See: https://docs.atuin.sh/latest/configuration/config
        '';
      };

      theme = mkOption {
        inherit (tomlFormat) type;
        default = {};
        description = ''
          Theme written to `ATUIN_THEME_DIR/<theme.name>.toml`

          ---

          See: https://docs.atuin.sh/latest/guide/theming
        '';
        example = literalExpression ''
          {
            theme.name = "My Theme";
            colors = {
              Base = "#000000";
              Title = "#FFFFFF";
            };
          }
        '';
      };

      configFile = mkOption {
        type = wlib.types.file config.pkgs;
        default.path = tomlFormat.generate "atuin-config.toml" config.settings;
        description = "Atuin configuration file.";
      };

      themeFile = mkOption {
        type = wlib.types.file config.pkgs;
        default.path = tomlFormat.generate "atuin-theme.toml" config.theme;
        description = "Atuin theme file.";
      };
    };

    config = let
      inherit (config.settings.theme) name;
    in {
      package = mkDefault config.pkgs.atuin;
      env =
        {
          ATUIN_CONFIG_DIR = mkDefault (toString (
            config.pkgs.linkFarm "atuin-config-dir" {
              "config.toml" = config.configFile.path;
            }
          ));
        }
        // optionalAttrs (
          hasAttrByPath ["theme" "name"] config.settings
          && ! elem name ["default" "default-powershell" "autumn" "marine"]
        ) {
          ATUIN_THEME_DIR = mkDefault (toString (
            config.pkgs.linkFarm "atuin-theme-dir" {
              "${name}.toml" = config.themeFile.path;
            }
          ));
        };
    };
  });

  atuin = module.apply {
    inherit pkgs;
    settings = {
      daemon = {
        enabled = true;
        autostart = true;
      };
      dotfiles.enabled = true;
      sync.records = true;
      ctrl_n_shortcuts = true;
      enter_accept = true;
      history_filter = [
        "^l(a|l|la|s|t)?( +|$)"
        "^cd( +|$)"
        "^(c|b)at( +|$)"
        "^vim?( +|$)"
        "^nvim( +|$)"
        "^env( +|$)"
        "^type( +|$)"
        "^which( +|$)"
        "^exit( +|$)"
        "^builtin( +|$)"
        "^[a-zA-Z]{1,4} *$"
      ];
      inline_height = 20;
      keymap_mode = "auto";
      logs.dir = "\${XDG_STATE_HOME:-$HOME/.local/state}/atuin/logs";
      style = "compact";
      theme.name = "catppuccin-mocha-blue";
      tmux.enabled = true;
      workspaces = true;
    };
    themeFile.path = pkgs.catppuccinSources
      .atuin + "/mocha/catppuccin-mocha-blue.toml";
  };
in
  atuin.wrapper
