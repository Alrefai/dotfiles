{
  pkgs,
  wrappers,
  ...
}: let
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
        ll = "eza -lho --git --git-repos";
        l = "ll -a";
        lt = pkgs.lib.concatStringsSep " " [
          "eza"
          "-lahoTL"
          "3"
          "--group-directories-first"
          "--icons"
          "--git-repos-no-status"
          "-I"
          "'.git$'"
          "--color"
          "always"
        ];
        tree = pkgs.lib.concatStringsSep " " [
          "eza"
          "-lahoT"
          "--group-directories-first"
          "--icons"
          "--git-repos-no-status"
          "-I"
          "'.git$'"
          "--color"
          "always"
        ];
      };

      integrations = {
        fzf.enable = true;
        atuin.enable = true;
        starship.enable = true;
        zoxide = {
          enable = true;
          flags = ["--no-cmd"];
        };
      };

      completion = {
        enable = true;
        extraCompletions = true;
        colors = true;
        caseInsensitive = true;
        fuzzySearch = true;
      };

      autoSuggestions.enable = true;

      history = {
        append = false;
        expanded = false;
        expireDupsFirst = true;
        file = "\${XDG_DATA_HOME:-$HOME/.local/share}/zsh/history";
        findNoDups = false;
        ignoreAllDups = false;
        ignoreDups = true;
        ignoreSpace = true;
        save = 500; # Number of history lines to save
        saveNoDups = false;
        share = true;
        size = 600; # Number of history lines to keep
      };
    };

    extraRC =
      #sh
      ''
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

        # Manually define z function for zoxide
        if command -v zoxide >/dev/null; then
          function z() { __zoxide_z "$@" }
          function zi() { __zoxide_zi "$@" }
        fi

        alias -g -- G='| grep -i'
        alias -g -- HELP='--help | bat --plain --language help'
        alias -g -- RG='| rg -i'

      '';
  };
in {
  wrappers.zsh = zsh.wrapper;
}
