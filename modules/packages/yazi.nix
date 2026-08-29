{
  pkgs,
  wrappers,
  ...
}: let
  mkLinkFarm = pkgs.lib.mapAttrsToList (name: path: {
    name = name + ".yazi";
    inherit path;
  });

  plugins = pkgs.linkFarm "yazi-plugins" (mkLinkFarm {
    inherit (pkgs.yaziPlugins) chmod full-border toggle-pane starship;
  });

  catppuccinBat = pkgs.catppuccinSources.bat + "/Catppuccin Mocha.tmTheme";

  catppuccinYazi = pkgs.catppuccinSources
    .yazi + "/mocha/catppuccin-mocha-blue.toml";

  yaziTheme = pkgs.runCommand "yazi-catppuccin-mocha-blue-oled.toml" {} ''
    substitute "${catppuccinYazi}" "$out" --replace-fail \
      "~/.config/yazi/Catppuccin-mocha.tmTheme" "${catppuccinBat}"
  '';

  yazi = wrappers.wrapperModules.yazi.apply {
    inherit pkgs;

    settings = {
      mgr = {
        sort_dir_first = true;
        sort_reverse = true;
        show_hidden = true;
        show_symlink = true;
      };
    };

    keymap = {
      mgr.prepend_keymap = [
        {
          on = ["T" "T"];
          run = "plugin toggle-pane max-preview";
          desc = "Maximize or restore the preview pane";
        }
        {
          on = ["T" "t"];
          run = "plugin toggle-pane min-preview";
          desc = "Show or hide the preview pane";
        }
        {
          on = ["c" "m"];
          run = "plugin chmod";
          desc = "Chmod on selected files";
        }
      ];
    };

    "theme.toml".path = yaziTheme;

    extraFiles = [
      {
        name = "init.lua";
        file = {
          content =
            # lua
            ''
              require("full-border"):setup {
                -- Available values: ui.Border.PLAIN, ui.Border.ROUNDED
                type = ui.Border.ROUNDED,
              }

              require("starship"):setup()
            '';
        };
      }
      {
        name = "plugins";
        file = {path = plugins;};
      }
    ];

    extraPackages = [pkgs.wrappers.starship];
  };
in
  yazi.wrapper
