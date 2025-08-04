{
  config,
  lib,
  pkgs,
  inputs,
  username,
  ...
}: let
  inherit
    (inputs)
    minvim
    mitmux
    tmux-sessionx
    tmux-window-name
    tmux-network-bandwidth
    yazi-plugins
    starship-yazi
    ;

  uutils-coreutils-fzf-compat = pkgs.uutils-coreutils-noprefix.overrideAttrs (
    oldAttrs: {
      postInstall =
        (oldAttrs.postInstall or "")
        +
        # bash
        ''
          # Create GNU-compatible wrapper for mkfifo
          mv $out/bin/mkfifo $out/bin/.mkfifo-uutils

          cat > $out/bin/mkfifo << 'EOF'
          #!/usr/bin/env bash
          set -euo pipefail

          # Find the actual uutils coreutils multicall binary
          uutils_coreutils="$(dirname "$(readlink -f "$0")")/.mkfifo-uutils"

          # Handle GNU coreutils compatibility for fzf
          if [[ $# -ge 2 && "$1" == "-m" && "$2" == "o+w" ]]; then
            # Convert GNU syntax to octal: o+w = 622 (owner rw, group w, other w)
            shift 2
            exec "$uutils_coreutils" mkfifo -m 622 "$@"
          else
            # Pass through all other arguments unchanged
            exec "$uutils_coreutils" mkfifo "$@"
          fi
          EOF
          chmod +x $out/bin/mkfifo
        '';
    }
  );
in {
  # Avoid using `with` expression; replace it with the following expression:
  #
  # ```
  # packages = builtins.attrValues {
  #   inherit (pkgs) curl jq;
  # };
  # ```
  # ---
  #
  # references:
  # https://nix.dev/guides/best-practices#with-scopes
  #
  nix = {
    gc.automatic = true;
    package = pkgs.nix;
    settings = {
      experimental-features = ["nix-command" "flakes"];
      use-xdg-base-directories = true;
    };
  };

  home = {
    # Home Manager needs a bit of information about you and the paths it should
    # manage.
    inherit username;
    homeDirectory =
      if pkgs.stdenv.isDarwin
      then "/Users/${username}"
      else "/home/${username}";

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
    packages =
      builtins.attrValues {
        inherit
          (pkgs)
          _1password-cli
          bottom # Modern top (command: btm)
          corepack_latest
          curl
          dog # Modern DNS client (better than dig)
          dua # Disk Usage Analyzer
          marksman # markdown language server
          neovim
          nixd # nix language server
          nodejs_latest
          perl
          pnpm-shell-completion
          procs # Modern ps with colors
          ripgrep-all # ripgrep with search in PDFs, E-Books, zip, and more
          tmux
          uutils-findutils # Rust implementation of findutils
          wget
          xh # Friendly and fast tool for sending HTTP requests
          yq-go #! required for tmux-nerd-font-window-name plugin
          ;
        inherit
          (pkgs.devTools)
          # custom pkgs from treefmt.nix
          alejandra # nix formatter
          shellcheck # sh linter
          shfmt # sh formatter
          statix # nix linter
          treefmt # universal code formatting tool
          ;
      }
      ++ [
        uutils-coreutils-fzf-compat # Rust coreutils with GNU-compatible mkfifo wrapper
      ]
      ++ pkgs.lib.lists.optionals pkgs.stdenv.isLinux (builtins.attrValues {
        inherit
          (pkgs)
          gcc
          gnumake
          oniux
          unzip
          ;
      });

    activation = {
      restoreNeovimPlugins =
        lib.hm.dag.entryAfter ["writeBoundary"]
        # bash
        ''
          if [[ -d "${config.xdg.configHome}/nvim" ]]; then
            PATH="/usr/bin:/bin:/usr/sbin:/sbin:$PATH"
            PATH="/nix/var/nix/profiles/default/bin:$PATH"
            PATH="${config.xdg.stateHome}/nix/profile/bin:$PATH"
            NVIM_APPNAME=nvim run --silence nvim --headless "+Lazy! restore" +qa
          fi
        '';
    };

    # Home Manager is pretty good at managing dotfiles. The primary way to manage
    # plain files is through 'home.file'.
    file = {
      # Building this configuration will create a copy of 'dotfiles/screenrc' in
      # the Nix store. Activating the configuration will then make '~/.screenrc'
      # a symlink to the Nix store copy.
      # ".profile".source = ./dotfiles/profile;
      ".ssh/allowed_signers".source = ./dotfiles/ssh/allowed_signers;
      ".ssh/github.pub".source = ./dotfiles/ssh/github.pub;
      ".local/bin".source = ./bin;

      # You can also set the file content immediately.
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
      # TERM = "xterm-256color";
      COLORTERM = "truecolor"; #! Important: for delta catppuccin theme

      # Node
      # NPM_CONFIG_USERCONFIG = "${config.xdg.configHome}/npm/npmrc";
      NPM_CONFIG_CACHE = "${config.xdg.cacheHome}/npm";
      PNPM_HOME = "${config.xdg.dataHome}/pnpm";
      NODE_REPL_HISTORY = "${config.xdg.stateHome}/node_repl_history";
    };
    sessionPath = [
      "$HOME/.local/bin"
      "${config.home.sessionVariables.PNPM_HOME}"
      "${config.xdg.dataHome}/npm-global/bin"
    ];
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

      # tmux
      attach = "tmux attach-session -t";
      switch = "tmux switch-client -t";
      tmk = "tmux kill-session -t";
      tls = "tmux ls";

      # treefmt
      fmt = "treefmt -vv";

      tarx = "tar -xzvf";

      # Git
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
      lt = "eza -lahoTL 3 --group-directories-first --icons --git-repos-no-status -I '.git$' --color always";
      tree = "eza -lahoT --group-directories-first --icons --git-repos-no-status -I '.git$' --color always";

      # fix lazygit delta pager truecolor in tmux
      lazygit = "TERM=screen-256color lazygit";

      # vercel
      vercel = "vercel --global-config ~/.config/vercel";
      vc = "vercel --global-config ~/.config/vercel";
    };
  };

  xdg = {
    enable = true;
    configFile = {
      "git/message".source = ./dotfiles/git/message;
      "nvim" = {
        source = minvim;
        recursive = true;
      };
      "tmux/tmux.conf".source = "${mitmux}/.tmux.conf";
      "tmux/tmux.conf.local".source = "${mitmux}/.tmux.conf.local";
      "wezterm" = {
        source = ./dotfiles/wezterm;
        recursive = true;
      };
    };
    dataFile = let
      overrideDistination = {postInstall ? "", ...}: {
        postInstall =
          postInstall
          +
          # sh
          ''
            read -r TMP_DIR < <(mktemp -d)
            cp -r $target/* $TMP_DIR
            rm -rf $out/*
            cp -r $TMP_DIR/* $out
            rm -rf $TMP_DIR
          '';
      };
    in {
      "tmux/plugins/tmux-cpu".source = pkgs.tmuxPlugins
        .cpu.overrideAttrs overrideDistination;
      "tmux/plugins/tmux-yank".source = pkgs.tmuxPlugins
        .yank.overrideAttrs overrideDistination;
      "tmux/plugins/tmux-copycat".source = pkgs.tmuxPlugins
        .copycat.overrideAttrs overrideDistination;
      "tmux/plugins/tmux-resurrect".source = pkgs.tmuxPlugins
        .resurrect.overrideAttrs overrideDistination;
      "tmux/plugins/tmux-continuum".source = pkgs.tmuxPlugins
        .continuum.overrideAttrs overrideDistination;
      "tmux/plugins/vim-tmux-navigator".source = pkgs.tmuxPlugins
        .vim-tmux-navigator.overrideAttrs overrideDistination;
      "tmux/plugins/tmux-sessionx".source = tmux-sessionx;
      "tmux/plugins/tmux-nerd-font-window-name".source = tmux-window-name;
      "tmux/plugins/tmux-network-bandwidth".source = tmux-network-bandwidth;
    };
  };

  # Enable Catppucin for all available programs.
  catppuccin = {
    enable = true;
    accent = "blue";
  };

  # Let Home Manager install and manage itself.
  programs = {
    home-manager.enable = true;

    atuin = {
      enable = true;
      settings = {
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
        style = "compact";
      };
    };

    bat = {
      enable = true;
      config = {
        italic-text = "always";
        style = "full";
      };
    };

    bash = {
      enable = true;
      historyControl = ["ignoreboth"];
      historyFile = "${config.xdg.stateHome}/bash/bash_history";
      profileExtra =
        # bash
        ''
          # Homebrew
          if [[ -e /usr/local/bin/brew ]]; then
            export HOMEBREW_PREFIX=/usr/local
          elif [[ -e /opt/homebrew/bin/brew ]]; then
            export HOMEBREW_PREFIX=/opt/homebrew
          fi
          if [[ $HOMEBREW_PREFIX ]]; then
            eval "$("$HOMEBREW_PREFIX"/bin/brew shellenv)"
            export HOMEBREW_NO_ANALYTICS=1
          fi

          # use bat as a colorizing pager for man pages
          if command -v bat >/dev/null; then
            export MANPAGER="sh -c 'sed -u -e \"s/\\x1B\[[0-9;]*m//g; s/.\\x08//g\" | bat -p -l man'"
          fi
        '';
      initExtra =
        # bash
        ''
          # vim-style keybindings
          set -o vi

          # manually define z function for zoxide
          if command -v zoxide >/dev/null; then
            function z() { __zoxide_z "$@"; }
            function zi() { __zoxide_zi "$@"; }
          fi

          # 1password-cli config:
          # - load op (1Password CLI) completion
          # - source op (1Password CLI) plugins
          #
          # ---
          #
          # ref: https://developer.1password.com/docs/cli/shell-plugins/github#step-3-source-the-pluginssh-file
          if command -v op >/dev/null; then
            eval "$(op completion bash)"
            # compdef _op op
            [[ -f ${config.xdg.configHome}/op/plugins.sh ]] &&
              source "${config.xdg.configHome}"/op/plugins.sh
          fi
        '';
      bashrcExtra =
        # bash
        ''
          # Ghostty shell integration for Bash.
          # This should be at the top of your bashrc!
          if [[ $GHOSTTY_RESOURCES_DIR ]]; then
            builtin source "$GHOSTTY_RESOURCES_DIR/shell-integration/bash/ghostty.bash"
          fi

          # Create ssh sockets directory with the following code:
          if [[ ! -d /tmp/ssh-sockets/ ]]; then
            mkdir -p /tmp/ssh-sockets
            chmod 700 /tmp/ssh-sockets
          fi
        '';
    };

    direnv = {
      enable = true;
      nix-direnv.enable = true;
      silent = true;
    };

    eza = {
      enable = true;
      git = true;
      icons = "auto";
      extraOptions = [
        "--group-directories-first"
        "--header"
      ];
    };

    fd = {
      enable = true;
      hidden = true;
    };

    fzf = rec {
      enable = true;
      changeDirWidgetCommand =
        # bash
        ''
          fd --type d --color always --follow --hidden --no-require-git \
            --exclude 'Library/' \
            --exclude '.cache/' \
            --exclude '.git/'
        '';
      changeDirWidgetOptions = [
        "--preview 'eza --icons --color always --tree --level 3 {} | head -200'"
      ];
      colors = {
        bg = pkgs.lib.mkForce "-1";
        fg = pkgs.lib.mkForce "-1";
        "bg+" = pkgs.lib.mkForce "-1";
      };
      defaultCommand =
        # bash
        ''
          fd --type f \
            --color always \
            --follow \
            --hidden \
            --no-require-git \
            -E '.git/'
        '';
      defaultOptions = [
        "--bind J:down,K:up,ctrl-a:select-all,ctrl-d:deselect-all,ctrl-t:toggle-all"
        "--no-height"
        "--border"
        "--ansi"
        "--tmux bottom,40%"
      ];
      fileWidgetCommand = defaultCommand;
      fileWidgetOptions = [
        "--preview 'bat --color always --style numbers --line-range :500 {}'"
      ];
      historyWidgetOptions = [
        "--preview 'echo {}'"
        "--preview-window down:3:wrap"
        "--bind '?:toggle-preview'"
        "--sort"
        "--exact"
        "--height '~14'"
      ];
    };

    gh = {
      enable = true;
      extensions = builtins.attrValues {
        inherit
          (pkgs)
          gh-eco
          gh-f
          gh-notify
          gh-poi
          ;
      };
      gitCredentialHelper.enable = false;
      settings = {
        # What protocol to use when performing git operations.
        # Supported values: ssh, https
        git_protocol = "ssh";

        # What editor gh should run when creating issues, pull requests, etc.
        # If blank, will refer to environment.
        editor = "nvim";

        # When to interactively prompt. This is a global config that cannot be
        # overridden by hostname. Supported values: enabled, disabled
        prompt = "enabled";

        # A pager program to send command output to, e.g. "less".
        # Set the value to "cat" to disable the pager.
        pager = "delta";

        # Aliases allow you to create nicknames for gh commands.
        aliases = {
          co = "pr checkout";
          pv = "pr view";
          prs = "f -p"; # show PRs
          l = "f -l"; # show git logs
        };
      };
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
        commit.template = "~/${config.xdg.configFile."git/message".target}";
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

        # Ignore icon files
        # https://stackoverflow.com/a/65429032/9185553
        "Icon?"
        "![iI]con[_a-zA-Z0-9]"

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

    ghostty = {
      enable = true;
      package = null;
      settings = {
        # Font configuration
        font-family = "JetBrains Mono";
        font-feature = [
          # `Ww` with lover middle connection
          "cv07"
          # `y` with different ascender construction
          "cv11"
          # `u` with traditional construction
          "cv12"
          # `$` with broken bar
          "cv14"
        ];

        # Color scheme configuration
        theme = "catppuccin-mocha";
        background = "#000000";
        foreground = "#b3b1ad";
        cursor-color = "#b3b1ad";
        cursor-text = "#000000";

        # Window configuration
        macos-titlebar-style = "hidden";
        window-padding-color = "background";
        shell-integration-features = "no-cursor";

        # Keybind configuration
        keybind = ["alt+shift+space=toggle_quick_terminal"];
      };
    };

    jq.enable = true;

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

    ripgrep.enable = true;

    ssh = {
      enable = true;
      controlMaster = "auto";
      controlPersist = "600";
      extraConfig = ''
        ConnectTimeout 3
        PubkeyAuthentication no
        IdentitiesOnly yes
      '';
      hashKnownHosts = true;
      includes = ["~/.ssh/config.d/*.conf"];
      matchBlocks = {
        "github.com github" = {
          hostname = "github.com";
          user = "git";
          identityFile = "~/.ssh/github.pub";
          extraOptions = {
            "PubkeyAuthentication" = "yes";
          };
        };
      };
    };

    starship = {
      enable = true;
      settings = {
        "$schema" = "https://starship.rs/config-schema.json";
        command_timeout = 3000;
        container = {disabled = true;};
        git_branch = {symbol = " ";};
        hostname = {ssh_symbol = " ";};
        nix_shell = {heuristic = true;};
        os = {
          disabled = false;
          symbols = {
            Arch = " ";
            Macos = "";
            NixOS = " ";
            Ubuntu = " ";
          };
        };
        shell = {
          disabled = false;
          format = "[$indicator]($style)";
          bash_indicator = " ";
          zsh_indicator = "";
        };
      };
    };

    yazi = {
      enable = true;
      enableZshIntegration = true;
      enableBashIntegration = true;
      settings = {
        mgr = {
          sort_by = "mtime";
          sort_dir_first = true;
          sort_reverse = true;
          show_hidden = true;
          show_symlink = true;
        };
      };
      plugins = {
        chmod = "${yazi-plugins}/chmod.yazi";
        full-border = "${yazi-plugins}/full-border.yazi";
        toggle-pane = "${yazi-plugins}/toggle-pane.yazi";
        starship = starship-yazi;
      };

      initLua =
        # lua
        ''
          require("full-border"):setup {
            -- Available values: ui.Border.PLAIN, ui.Border.ROUNDED
            type = ui.Border.ROUNDED,
          }

          require("starship"):setup()
        '';

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
    };

    zoxide = {
      enable = true;
      options = ["--no-cmd"];
    };

    zsh = {
      enable = true;
      dotDir = "${config.xdg.configHome}/zsh";
      envExtra =
        # bash
        ''
          [[ -e ~/.profile ]] && emulate sh -c 'source ~/.profile'
          # don't use global env as it will slow us down
          skip_global_compinit=1
        '';
      initContent = let
        initExtraBeforeCompInit =
          lib.mkOrder 500
          # sh
          ''
            # See available completion styles with 'compstyle -l'
            zstyle ':plugin:ez-compinit' 'compstyle' 'zshzoo'
          '';
        initExtra =
          lib.mkOrder 1000
          # sh
          ''
            # Ghostty shell integration for ZSH.
            # This should be at the top of your zshrc!
            if [[ $GHOSTTY_RESOURCES_DIR ]]; then
              builtin source "$GHOSTTY_RESOURCES_DIR/shell-integration/zsh/ghostty-integration"
            fi

            # extra options
            setopt auto_list            # auto list choices on ambiguous completion
            setopt auto_menu            # automatically use menu completion
            setopt always_to_end        # move cursor to end if word had one match
            setopt interactive_comments # allow comments in interactive shells
            setopt ignoreeof            # Disable closing shell with C-d
            setopt globdots             # Show hidden files and folders
            setopt complete_aliases     # enable completion for aliased commands

            # autosuggestions key bindings
            bindkey '^ ' autosuggest-accept

            # manually define z function for zoxide
            if command -v zoxide >/dev/null; then
              function z() { __zoxide_z "$@" }
              function zi() { __zoxide_zi "$@" }
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
      in
        lib.mkMerge [initExtraBeforeCompInit initExtra];
      defaultKeymap = "viins";
      autocd = true;
      antidote = {
        enable = true;
        plugins = [
          "mattmc3/ez-compinit"
        ];
        useFriendlyNames = true;
      };
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
      completionInit = ""; # managed by "mattmc3/ez-compinit" plugin
      history = {
        expireDuplicatesFirst = true;
        ignoreSpace = true;
        save = 500; # Number of history lines to save
        size = 600; # Number of history lines to keep
        path = "${config.xdg.stateHome}/zsh/zsh_history";
      };
      shellGlobalAliases = {
        G = "| grep -i";
        HELP = "--help | bat --plain --language help";
        RG = "| rg -i";
      };
    };
  };
}
