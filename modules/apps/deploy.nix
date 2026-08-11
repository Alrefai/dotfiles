{pkgs}: {
  deploy = {
    type = "app";
    program = pkgs.lib.getExe (pkgs.writeShellApplication {
      name = "deploy";
      runtimeInputs = builtins.attrValues {
        inherit (pkgs.deploy-rs) deploy-rs;
        inherit (pkgs) git;
      };
      text = ''
        read -r BRANCH < <(git branch --show-current)
        read -r COMMIT < <(git rev-parse --short HEAD)
        read -r TIMESTAMP < <(date '+%Y.%m.%dT%H:%M')

        exec env NIXOS_LABEL="build_$BRANCH:$COMMIT:$TIMESTAMP" deploy "$@"
      '';
    });
  };
}
