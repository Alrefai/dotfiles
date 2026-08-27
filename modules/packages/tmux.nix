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
        cpu
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
      grep -vF 'TMUX_PLUGIN_MANAGER_PATH' "${mitmux}/.tmux.conf.local" > "$out"
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
