{
  config,
  pkgs,
  ...
}: let
  shellAliases = {
    # bat --plain for unformatted cat
    catp = "bat -P";

    # replace cat with bat
    cat = "bat";

    # zoxide for smart cd
    cd = "z";

    # devbox helpers
    dbr = "devbox run";
    dbgr = "devbox global run";
    dbgl = "devbox global list";
    dbga = "devbox global add";
    dbgd = "devbox global rm";
    cddevbox = "cd $DEVBOX_GLOBAL_ROOT";

    # home-manager
    hsw = "home-manager switch -b bak --flake \${DEVBOX_GLOBAL_ROOT%/*}/default";

    # shell
    c = "clear";
    r = "exec $SHELL"; # Reload SHELL
    rr = "rm -rf";

    ## Enforce interaction
    rm = "rm -i";
    rd = "rm -ri";
    cp = "cp -i";
    mv = "mv -i";

    vi = "nvim";

    ## tmux
    attach = "tmux attach-session -t";
    switch = "tmux switch-client -t";
    tmk = "tmux kill-session -t";
    tls = "tmux ls";

    # treee="tree -CI node_modules";
    tarx = "tar -xzvf";

    ## Git
    g = "git status -s";
    # ga="git add";
    gb = "git branch";
    # gc="git commit -m";
    # gca="git commit -am";
    gco = "git checkout";
    gcob = "git checkout -b";
    # grpr="git remote prune origin";
    gl = "git log --oneline --graph";

    ## eza aliases
    # eza = "eza --group-directories-first --git-ignore -F auto --icons auto";
    ls = "eza -1";
    lsa = "ls -a";
    ll = "eza -lho --git --git-repos";
    l = "ll -a";
    # lt="eza -lahT --ignore-glob=".git|$(ignore)"";

    # vercel
    "{vc,vercel}" = "vercel --global-config ~/.config/vercel";
  };
in {
  home = {
    # Home Manager needs a bit of information about you and the paths it should
    # manage.
    username = "mohammed";
    homeDirectory =
      if pkgs.stdenv.isDarwin
      then "/Users/mohammed"
      else "/home/mohammed";

    preferXdgDirectories = true;

    # This value determines the Home Manager release that your configuration is
    # compatible with. This helps avoid breakage when a new Home Manager release
    # introduces backwards incompatible changes.
    #
    # You should not change this value, even if you update Home Manager. If you do
    # want to update the value, then make sure to first check the Home Manager
    # release notes.
    stateVersion = "24.05"; # Please read the comment before changing.

    # The home.packages option allows you to install Nix packages into your
    # environment.
    packages = with pkgs; [
      atuin
      eza
      bat
      delta
      direnv
      fd
      fzf
      gh
      jq
      lazygit
      ripgrep
      starship
      tmux
      tree
      yazi
      yq
      zoxide

      # # It is sometimes useful to fine-tune packages, for example, by applying
      # # overrides. You can do that directly here, just don't forget the
      # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
      # # fonts?
      # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

      # # You can also create simple shell scripts directly inside your
      # # configuration. For example, this adds a command 'my-hello' to your
      # # environment:
      # (pkgs.writeShellScriptBin "my-hello" ''
      #   echo "Hello, ${config.home.username}!"
      # '')
    ];

    # Home Manager is pretty good at managing dotfiles. The primary way to manage
    # plain files is through 'home.file'.
    file = {
      # # Building this configuration will create a copy of 'dotfiles/screenrc' in
      # # the Nix store. Activating the configuration will then make '~/.screenrc' a
      # # symlink to the Nix store copy.
      ".profile".source = dotfiles/profile;

      # # You can also set the file content immediately.
      # ".gradle/gradle.properties".text = ''
      #   org.gradle.console=verbose
      #   org.gradle.daemon.idletimeout=3600000
      # '';
    };

    # Home Manager can also manage your environment variables through
    # 'home.sessionVariables'. These will be explicitly sourced when using a
    # shell provided by Home Manager. If you don't want to manage your shell
    # through Home Manager then you have to manually source 'hm-session-vars.sh'
    # located at either
    #
    #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
    #
    # or
    #
    #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
    #
    # or
    #
    #  /etc/profiles/per-user/mohammed/etc/profile.d/hm-session-vars.sh
    #
    sessionVariables = {
      # EDITOR = "vim";
    };
    sessionPath = [];
  };

  # Enable Catppucin for all available programs.
  catppuccin.enable = true;

  # Let Home Manager install and manage itself.
  # programs.home-manager.enable = true;
  programs = {
    atuin = {enable = true;};

    eza = {
      enable = true;
      git = true;
      icons = true;
      extraOptions = [
        "--group-directories-first"
        "--header"
        "--git-ignore"
      ];
    };

    bat = {
      enable = true;
      config = {
        italic-text = "always";
        style = "full";
      };
    };

    fd = {
      enable = true;
      hidden = true;
    };

    fzf = {
      enable = true;
      changeDirWidgetCommand = "fd --type d";
      changeDirWidgetOptions = [
        "--preview 'tree -C {} | head -200'"
      ];
      defaultCommand = "fd --type f";
      fileWidgetCommand = "fd --type f";
      fileWidgetOptions = [
        "--preview 'bat --color=always --style=numbers --line-range=:500 {}'"
      ];
    };

    jq = {enable = true;};

    lazygit = {enable = true;};

    ripgrep = {enable = true;};

    starship = {enable = true;};

    tmux = {
      enable = true;
      baseIndex = 1;
      historyLimit = 5000;
      keyMode = "vi";
      mouse = true;
      newSession = true;
      shortcut = "s";
    };

    yazi = {
      enable = true;
      enableZshIntegration = true;
    };

    zoxide = {enable = true;};

    zsh = {
      enable = true;
      dotDir = ".config/zsh";
      envExtra = ''
        [[ -e ~/.profile ]] && emulate sh -c 'source ~/.profile'
        # don't use global env as it will slow us down
        skip_global_compinit=1
      '';
      initExtraBeforeCompInit = ''
        # add devbox bits to zsh
        if command -v devbox >/dev/null; then
          eval "$(devbox global shellenv)"
          fpath+=(
            $DEVBOX_GLOBAL_PREFIX/share/zsh/site-functions
            $DEVBOX_GLOBAL_PREFIX/share/zsh/$ZSH_VERSION/functions
            $DEVBOX_GLOBAL_PREFIX/share/zsh/vendor-completions
          )
        fi
      '';
      initExtra = ''
        # extra options
        setopt auto_list            # auto list choices on ambiguous completion
        setopt auto_menu            # automatically use menu completion
        setopt always_to_end        # move cursor to end if word had one match
        setopt interactive_comments # allow comments in interactive shells
        setopt ignoreeof            # Disable closing shell with C-d

        # use bat as a colorizing pager for man pages
        if command -v bat >/dev/null; then
          export MANPAGER="sh -c 'col -bx | bat -l man -p'"
        fi

        if command -v devbox >/dev/null; then
          source <(devbox completion zsh)
        fi

        # Create ssh sockets directory with the following code:
        if [[ ! -d /tmp/ssh-sockets/ ]]; then
          mkdir -p /tmp/ssh-sockets
          chmod 700 /tmp/ssh-sockets
        fi

        # 1password-cli config:
        # - load op (1Password CLI) completion
        # - source op (1Password CLI) plugins
        #
        # ---
        #
        # ref: https://developer.1password.com/docs/cli/shell-plugins/github#step-3-source-the-pluginssh-file
        if command -v op >/dev/null; then
          eval "$(op completion zsh)"
          # compdef _op op
          source "$HOME"/.config/op/plugins.sh
        fi
      '';
      defaultKeymap = "viins";
      autocd = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
      history = {
        expireDuplicatesFirst = true;
        ignoreSpace = true;
        save = 500; # Number of history lines to save
        size = 600; # Number of history lines to keep
        path = "${config.xdg.dataHome}/zsh/zsh_history";
      };
      inherit shellAliases;
    };
  };
}
