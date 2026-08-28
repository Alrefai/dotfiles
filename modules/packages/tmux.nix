{
  mitmux,
  pkgs,
  tmux-network-bandwidth,
  tmux-sessionx,
  tmux-window-name,
  tpm,
  wrappers,
  ...
}:
wrappers.lib.wrapPackage {
  inherit pkgs;

  package = pkgs.tmux;

  runtimeInputs = pkgs.lib.attrValues {
    inherit
      (pkgs)
      tmux
      perl
      ;
  };

  flags = {"-f" = mitmux + "/.tmux.conf";};

  env = let
    plugins = {
      inherit
        (pkgs.tmuxPlugins)
        yank
        copycat
        resurrect
        continuum
        vim-tmux-navigator
        ;
    };

    mkLinkFarm = pkgs.lib.mapAttrsToList (name: outPath: {
      name =
        if name == "vim-tmux-navigator"
        then name
        else "tmux-" + name;
      path = outPath + "/share/tmux-plugins/" + name;
    });
  in {
    TMUX_CONF = mitmux + "/.tmux.conf";

    TMUX_CONF_LOCAL = toString (pkgs.runCommand "tmux.conf.local" {} ''
      grep -vF \
        -e 'TMUX_PLUGIN_MANAGER_PATH' \
        -e 'tmux-plugins/tmux-cpu' \
        -e '@cpu_percentage_format' \
        -e '@ram_percentage_format' \
        "${mitmux}/.tmux.conf.local" > "$out"

      PATTERN='  #{cpu_icon}#{cpu_percentage}  #{ram_icon}#{ram_percentage}'

      substitute "$out" "$out" --replace-fail "$PATTERN" ""
    '');

    TMUX_PLUGIN_MANAGER_PATH = toString (pkgs.linkFarm "tmux-plugins-dir" (
      mkLinkFarm plugins
      ++ [
        {
          name = "tpm";
          path = tpm;
        }
        {
          name = "tmux-sessionx";
          path = tmux-sessionx;
        }
        {
          name = "tmux-nerd-font-window-name";
          path = tmux-window-name;
        }
        {
          name = "tmux-network-bandwidth";
          path = tmux-network-bandwidth;
        }
      ]
    ));
  };
}
