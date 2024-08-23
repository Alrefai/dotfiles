{
  config,
  pkgs,
  ...
}: {
  nix = {
    package = pkgs.nixVersions.nix_2_23;
    gc.automatic = true;
    extraOptions = ''
      trusted-users = mohammed
      experimental-features = fetch-tree flakes nix-command
    '';
  };

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
    packages = with pkgs;
      [
        _1password
        curl
        direnv
        gh
        neovim
        tree
        wget
        yq

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
      ]
      ++ lib.lists.optionals stdenv.isLinux [gcc gnumake unzip];

    # Home Manager is pretty good at managing dotfiles. The primary way to manage
    # plain files is through 'home.file'.
    file = {
      # # Building this configuration will create a copy of 'dotfiles/screenrc' in
      # # the Nix store. Activating the configuration will then make '~/.screenrc' a
      # # symlink to the Nix store copy.
      ".profile".source = ./dotfiles/profile;
      ".ssh/allowed_signers".source = ./dotfiles/ssh/allowed_signers;
      ".local/bin".source = ./bin;

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
      # General
      EDITOR = "nvim";
      VISUAL = "nvim";
      # BROWSER = "open";
      # LANG = "en_US.UTF-8";
      # LC_ALL = "en_US.UTF-8";

      # Custom excutable programs
      XDG_BIN_HOME = "$HOME/.local/bin";

      # Less
      PAGER = "less";
      LESSHISTFILE = "${config.xdg.stateHome}/less/history";

      # Terminal
      TERM = "xterm-256color";
      COLORTERM = "truecolor"; #! Important: for delta catppuccin theme

      # Node
      # NPM_CONFIG_USERCONFIG = "${config.xdg.configHome}/npm/npmrc";
      NPM_CONFIG_CACHE = "${config.xdg.cacheHome}/npm";
      PNPM_HOME = "${config.xdg.dataHome}/pnpm";
      NODE_REPL_HISTORY = "${config.xdg.stateHome}/node_repl_history";
    };
    sessionPath = [
      "${config.xdg.dataHome}/npm-global/bin"
      "${config.home.sessionVariables.PNPM_HOME}"
      "$HOME/.local/bin"
    ];
    shellAliases = {
      # bat --plain for unformatted cat
      catp = "bat -P";

      # replace cat with bat
      cat = "bat";

      # zoxide for smart cd
      cd = "z";

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
  };

  xdg = {
    enable = true;
    configFile = {
      "nvim" = {
        source = dotfiles/config/nvim;
        recursive = true;
      };
    };
  };

  # Enable Catppucin for all available programs.
  catppuccin.enable = true;

  # Let Home Manager install and manage itself.
  programs = {
    home-manager = {enable = true;};

    atuin = {enable = true;};

    bat = {
      enable = true;
      config = {
        italic-text = "always";
        style = "full";
      };
    };

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

    git = {
      enable = true;
      userName = "Mohammed Alrefai";
      userEmail = "mohammed@refam.io";
      delta = {
        enable = true;
        options.navigate = true; # use n and N to move between diff sections
      };
      extraConfig = {
        merge.conflictstyle = "diff3";
        diff.colorMoved = "default";
        init.defaultBranch = "main";
        rebase.updateRefs = true;
        user.signingkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOFpuK6A0N/8InMCdhyKNCOiWH5UkGnahLzJ3U0Niwut";
        commit.gpgSign = true;
        gpg = {
          format = "ssh";
          ssh = {
            allowedSignersFile = "~/.ssh/allowed_signers";
            ${
              if pkgs.stdenv.isDarwin
              then "program"
              else null
            } = "/Applications/1Password.app/Contents/MacOS/op-ssh-sign";
          };
        };
      };
      aliases = {
        delete-local-merged = ''
          !git fetch && git branch --merged \
          | grep -vE 'master|dev|main|staging' \
          | xargs git branch -d
        '';
      };
      ignores = [
        # General
        "DS_Store"
        "AppleDouble"
        "LSOverride"

        # Icon must end with two \r
        "con"

        # Thumbnails
        "_*"

        # Files that might appear in the root of a volume
        "DocumentRevisions-V100"
        "fseventsd"
        "Spotlight-V100"
        "TemporaryItems"
        "Trashes"
        "VolumeIcon.icns"
        "com.apple.timemachine.donotpresent"

        # Directories potentially created on remote AFP share
        "AppleDB"
        "AppleDesktop"
        "etwork Trash Folder"
        "emporary Items"
        "apdisk"

        # Created by https://www.toptal.com/developers/gitignore/api/node
        # Edit at https://www.toptal.com/developers/gitignore?templates=node

        ### Node ###
        # Logs
        "ogs"
        ".log"
        "pm-debug.log*"
        "arn-debug.log*"
        "arn-error.log*"
        "erna-debug.log*"

        # Diagnostic reports (https://nodejs.org/api/report.html)
        "eport.[0-9]*.[0-9]*.[0-9]*.[0-9]*.json"

        # Runtime data
        "ids"
        ".pid"
        ".seed"
        ".pid.lock"

        # Directory for instrumented libs generated by jscoverage/JSCover
        "ib-cov"

        # Coverage directory used by tools like istanbul
        "overage"
        ".lcov"

        # nyc test coverage
        "nyc_output"

        # Grunt intermediate storage (https://gruntjs.com/creating-plugins#storing-task-files)
        "grunt"

        # Bower dependency directory (https://bower.io/)
        "ower_components"

        # node-waf configuration
        "lock-wscript"

        # Compiled binary addons (https://nodejs.org/api/addons.html)
        "uild/Release"

        # Dependency directories
        "ode_modules/"
        "spm_packages/"

        # TypeScript v1 declaration files
        "ypings/"

        # TypeScript cache
        ".tsbuildinfo"

        # Optional npm cache directory
        "npm"

        # Optional eslint cache
        "eslintcache"

        # Microbundle cache
        "rpt2_cache/"
        "rts2_cache_cjs/"
        "rts2_cache_es/"
        "rts2_cache_umd/"

        # Optional REPL history
        "node_repl_history"

        # Output of 'npm pack'
        ".tgz"

        # Yarn Integrity file
        "yarn-integrity"

        # dotenv environment variables file
        "env"
        "env.test"

        # parcel-bundler cache (https://parceljs.org/)
        "cache"

        # Next.js build output
        "next"

        # Nuxt.js build / generate output
        "nuxt"
        "ist"

        # Gatsby files
        "cache/"
        # Comment in the public line in if your project uses Gatsby and not Next.js
        # https://nextjs.org/blog/next-9-1#public-directory-support
        # public

        # vuepress build output
        "vuepress/dist"

        # Serverless directories
        "serverless/"

        # FuseBox cache
        "fusebox/"

        # DynamoDB Local files
        "dynamodb/"

        # TernJS port file
        "tern-port"

        # Stores VSCode versions used for testing VSCode extensions
        "vscode-test"

        # End of https://www.toptal.com/developers/gitignore/api/node
      ];
    };

    jq = {enable = true;};

    lazygit = {
      enable = true;
      settings = {
        git.paging = {
          colorArg = "always";
          pager = "delta --paging=never";
        };
      };
    };

    less.enable = true;

    lesspipe.enable = true;

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
          [[ -f ${config.xdg.configHome}/op/plugins.sh ]] &&
            source "${config.xdg.configHome}"/op/plugins.sh
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
    };
  };
}
