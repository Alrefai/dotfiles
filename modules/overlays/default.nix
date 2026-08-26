{
  catppuccin,
  deploy-rs,
  lib,
  treefmtEval,
  ...
} @ inputs: final: prev: {
  catppuccinSources = catppuccin.packages.${final.stdenv.hostPlatform.system}
    .overrideScope (_: oldAttrs: let
    oled.mocha = {
      base = "000000";
      mantle = "010101";
      crust = "020202";
    };
  in {
    whiskers = final.symlinkJoin {
      name = "whiskers-wrapped";

      paths = [oldAttrs.whiskers];
      nativeBuildInputs = [final.makeBinaryWrapper];

      postBuild = ''
        wrapProgram $out/bin/whiskers \
          --add-flag ${
          final.lib.escapeShellArg "--color-overrides=${builtins.toJSON oled}"
        }
      '';

      meta.mainProgram = "whiskers";
    };
  });

  /**
  refs:
  - https://github.com/serokell/deploy-rs#overall-usage
  - https://github.com/serokell/deploy-rs/issues/163#issuecomment-2991603313
  */
  deploy-rs = let
    deploy-rsDefaultOverlays = deploy-rs.overlays.default final prev;
  in {
    inherit (prev) deploy-rs;
    inherit (deploy-rsDefaultOverlays.deploy-rs) lib;
  };

  devTools = let
    treefmtEvalPlatform = treefmtEval final;
  in {
    /**
    Make the treefmt command available in the shell using the specified
    configuration in `./treefmt.nix`.
    */
    treefmt = treefmtEvalPlatform.wrapper;
    /**
    Get access to the individual programs from treefmt, which could be
    useful to provide them to your IDE or editor.
    */
    inherit
      (treefmtEvalPlatform.programs)
      alejandra # nix formatter
      dprint # markdown formatter
      shellcheck # sh linter
      shfmt # sh formatter
      statix # nix linter
      ;
  };

  wrappers = lib.importModules ../packages (inputs // {pkgs = final;});
}
