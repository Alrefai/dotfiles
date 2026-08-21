{
  catppuccin,
  deploy-rs,
  lib,
  treefmtEval,
  ...
} @ inputs: final: prev: let
  deploy-rsDefaultOverlays = deploy-rs.overlays.default final prev;
  treefmtEvalPlatform = treefmtEval final;
in {
  /**
  refs:
  - https://github.com/serokell/deploy-rs#overall-usage
  - https://github.com/serokell/deploy-rs/issues/163#issuecomment-2991603313
  */
  deploy-rs = {
    inherit (prev) deploy-rs;
    inherit (deploy-rsDefaultOverlays.deploy-rs) lib;
  };

  devTools = {
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

  catppuccinSources = catppuccin.packages.${final.stdenv.hostPlatform.system}
    .sources;

  wrappers = lib.importModules ../packages (inputs // {pkgs = final;});
}
