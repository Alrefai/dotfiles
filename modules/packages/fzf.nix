{
  lib, # My own lib; use `pkgs.lib` for upstream
  pkgs,
  wrappers,
  ...
}: let
  inherit
    (pkgs.lib)
    concatStringsSep
    filterAttrs
    mapAttrs
    mapAttrsToList
    mkDefault
    mkOption
    optionals
    types
    ;

  module = wrappers.lib.wrapModule ({config, ...}: {
    /**
    Options and config were partially taken from home-manager fzf module
    - github.com/nix-community/home-manager/blob/master/modules/programs/fzf.nix
    */
    options = {
      colors = mkOption {
        type = types.attrsOf types.str;
        default = {};
        example = {
          bg = "#1e1e1e";
          "bg+" = "#1e1e1e";
          fg = "#d4d4d4";
          "fg+" = "#d4d4d4";
        };
        description = ''
          Color scheme options added to `FZF_DEFAULT_OPTS`. See
          <https://github.com/junegunn/fzf/wiki/Color-schemes>
          for documentation.
        '';
      };

      defaultCommand = mkOption {
        type = types.nullOr types.str;
        default = null;
        example = "fd --type f";
        description = ''
          The command that gets executed as the default source for fzf
          when running.
        '';
      };

      defaultOptions = mkOption {
        type = types.listOf types.str;
        default = [];
        example = [
          "--height 40%"
          "--border"
        ];
        description = ''
          Extra command line options given to fzf by default.
        '';
      };
    };

    config = let
      fzfEnvVars = filterAttrs (_name: value: value != [] && value != null) {
        FZF_DEFAULT_COMMAND = config.defaultCommand;
        FZF_DEFAULT_OPTS =
          config.defaultOptions
          ++ optionals (config.colors != {}) [
            "--color '${concatStringsSep "," (
              mapAttrsToList (name: value: "${name}:${value}") config.colors
            )}'"
          ];
      };
    in {
      package = mkDefault config.pkgs.fzf;
      env = mapAttrs (_: toString) fzfEnvVars;
    };
  });

  fzf = module.apply {
    inherit pkgs;
    /**
    Override catppuccin-fzf-mocha theme colors on `FZF_DEFAULT_OPTS_FILE`.
    */
    colors = {
      header = "#CDD6F4";
      label = "#6C7086";
    };
    defaultCommand = builtins.concatStringsSep " " [
      "${pkgs.lib.getExe' pkgs.fd "fd"}"
      "--type"
      "f"
      "--color"
      "always"
      "--follow"
      "--hidden"
      "--no-require-git"
      "--exclude"
      "'Library/'"
      "--exclude"
      "'.cache/'"
      "--exclude"
      "'.git/'"
      "2>/dev/null"
    ];
    env = let
      catppuccin = pkgs.catppuccinSources.fzf;

      header = pkgs.writeShellScript "fzf-header" ''
        awk '{NF=7}1' < <(
          ls -l --dereference --si --time-style '+%Y-%m-%d %H:%M' \
            -- "$1" 2>/dev/null
        )
      '';

      preview = pkgs.writeShellApplication {
        name = "fzf-preview";
        runtimeInputs = [pkgs.wrappers.bat pkgs.file];
        text = ''
          read -r type < <(file --brief --dereference --mime -- "$1")

          if [[ $type =~ =binary || $type =~ image/ ]]; then
            file --brief --dereference -- "$1"
            exit
          fi

          exec bat \
            --color always --style numbers --pager never --line-range :500 \
            -- "$1" 2>/dev/null
        '';
      };

      listLabel = pkgs.writeShellScript "fzf-transform-list-label" ''
        if [[ -z $FZF_QUERY ]]; then
          echo " $FZF_MATCH_COUNT items "
          exit
        fi

        echo " $FZF_MATCH_COUNT matches for [$FZF_QUERY] "
      '';

      previewLabel = pkgs.writeShellScript "fzf-transform-preview-label" ''
        [[ -n $1 ]] && printf ' Previewing [%s] ' "$1"
      '';

      replacements = import ../themes/catppuccin-mocha-oled.nix {
        inherit lib pkgs;
      };
    in {
      FZF_DEFAULT_OPTS_FILE = toString (pkgs.runCommand "fzf.rc" {} ''
        # Normalize the source colors to lowercase
        sed 's/[A-F]/\L&/g' \
          "${catppuccin}/themes/catppuccin-fzf-mocha.rc" > "$out"

        substitute "$out" "$out" \
          ${lib.substituteReplacements {inherit replacements;}}

        cat >> "$out" <<'EOF'
        --style=full
        --border
        --input-label=' Input '
        --header-label=' File Metadata '
        --preview='${pkgs.lib.getExe preview} {}'
        --preview-window=hidden
        --bind='ctrl-w:change-preview-window(up|right|)'
        --bind=ctrl-v:change-multi
        --bind=ctrl-a:select-all,ctrl-d:deselect-all,ctrl-t:toggle-all
        --bind='result:transform-list-label:${listLabel}'
        --bind='focus:transform-preview-label:${previewLabel} {}'
        --bind='focus:+transform-header:${header} {}'
        --no-height
        --tmux=center,80%,border-native
        --ansi
        EOF
      '');
    };
  };
in
  fzf.wrapper
