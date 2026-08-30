{
  ez-compinit,
  pkgs,
  wrappers,
  ...
}: let
  # Dependencies (including ez-compinit)
  inherit (pkgs.wrappers) eza bat fzf starship;
  inherit
    (pkgs)
    atuin
    nix-zsh-completions
    ripgrep
    zoxide
    zsh-completions
    ;

  # Helpers
  inherit (pkgs.lib) attrValues concatStringsSep getExe' makeBinPath;

  zsh = wrappers.wrapperModules.zsh.apply {
    inherit pkgs;
    settings = {
      shellAliases = {
        # bat --plain for unformatted cat
        catp = "bat -P";

        # replace cat with bat
        cat = "bat";

        # zoxide for smart cd
        cd = "z";
        cx = "zi";

        # change directory upward
        ".." = "cd ..";
        "..." = "cd ../..";
        "...." = "cd ../../..";
        "....." = "cd ../../../..";
        "......" = "cd ../../../../..";

        # print all occurrences in path with type command
        type = "type -a";

        # safely make directories
        mkdir = "mkdir -p";

        # convenient shell commands
        c = "clear";
        r = "exec $SHELL"; # Reload SHELL
        rr = "rm -rf";

        # Enforce interaction
        rm = "rm -i";
        rd = "rm -ri";
        cp = "cp -i";
        mv = "mv -i";

        # nvim
        vi = "nvim";

        # treefmt
        fmt = "treefmt -vv";

        tarx = "tar -xzvf";

        # Git
        g = "git status -s";
        gb = "git branch";
        gco = "git checkout";
        gcob = "git checkout -b";
        gl = "git log --oneline --graph";

        # eza
        ls = "eza -1";
        lsa = "ls -a";
        ll = "eza -lho";
        l = "ll -a";
        lt = concatStringsSep " " [
          "eza"
          "-lahoTL"
          "3"
          "-I"
          "'.git$'"
        ];
        tree = concatStringsSep " " [
          "eza"
          "-lahoT"
          "-I"
          "'.git$'"
        ];
      };

      completion = {
        enable = true;
        init =
          # sh
          ''
            # See available completion styles with 'compstyle -l'
            zstyle ':plugin:ez-compinit' 'compstyle' 'zshzoo'

            typeset -U path cdpath fpath manpath
            for profile in ''${(z)NIX_PROFILES}; do
              fpath+=(
                $profile/share/zsh/site-functions
                $profile/share/zsh/$ZSH_VERSION/functions
                $profile/share/zsh/vendor-completions
              )
            done

            fpath+=(
              ${nix-zsh-completions}/share/zsh/site-functions
              ${zsh-completions}/share/zsh/site-functions
            )

            # Load ez-compinit
            source ${ez-compinit}/ez-compinit.plugin.zsh
          '';
        extraCompletions = true;
        colors = false;
        caseInsensitive = true;
        fuzzySearch = false;
      };

      autoSuggestions.enable = true;

      history = {
        append = false;
        expanded = false;
        expireDupsFirst = true;
        file = "\${XDG_STATE_HOME:-$HOME/.local/state}/zsh/history";
        findNoDups = false;
        ignoreAllDups = false;
        ignoreDups = true;
        ignoreSpace = true;
        save = 500; # Number of history lines to save
        saveNoDups = false;
        share = true;
        size = 600; # Number of history lines to keep
      };

      env = let
        runTimePkgs = attrValues {
          inherit atuin eza bat fzf ripgrep starship zoxide;
        };
        extraPaths = makeBinPath runTimePkgs;
      in {PATH = "$PATH:${extraPaths}";}; # Prioritize system paths
    };

    extraRC =
      #sh
      ''
        if [[ $TERM != "dumb" ]]; then
          eval "$(${getExe' starship "starship"} init zsh)"
        fi

        eval "$(${getExe' zoxide "zoxide"} init zsh --no-cmd)"
        function z() { __zoxide_z "$@" }
        function zi() { __zoxide_zi "$@" }


        if [[ $options[zle] = on ]]; then
          eval "$(${getExe' atuin "atuin"} init zsh)"
          FZF_CTRL_R_COMMAND= source <(${getExe' fzf "fzf"} --zsh)
        fi

        # Make sure history file exists
        mkdir -p "$(dirname "$HISTFILE")"

        # Use viins keymap as the default
        bindkey -v

        # Autosuggestions key bindings
        bindkey '^ ' autosuggest-accept

        # Extra options
        setopt auto_list            # auto list choices on ambiguous completion
        setopt auto_menu            # automatically use menu completion
        setopt always_to_end        # move cursor to end if word had one match
        setopt interactive_comments # allow comments in interactive shells
        setopt ignoreeof            # Disable closing shell with C-d
        setopt globdots             # Show hidden files and folders
        setopt complete_aliases     # enable completion for aliased commands

        alias -g -- G='| grep -i'
        alias -g -- HELP='--help | bat --plain --language help'
        alias -g -- RG='| rg -i'

        source ${pkgs.zsh-syntax-highlighting
          + "/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"}
        ZSH_HIGHLIGHT_HIGHLIGHTERS=(main)
      '';
  };
in
  zsh.wrapper
