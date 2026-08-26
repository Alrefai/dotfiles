{pkgs, ...}: {
  projectRootFile = ".git/config";
  programs = {
    alejandra.enable = true;
    dprint = {
      enable = true;
      includes = ["{,**/}*.md"];
      settings = {
        incremental = true;
        lineWidth = 80;
        indentWidth = 2;
        useTabs = false;
        newLineKind = "lf";
        markdown.textWrap = "always";
        # https://plugins.dprint.dev
        plugins = pkgs.dprint-plugins.getPluginList (
          plugins: [plugins.dprint-plugin-markdown]
        );
      };
    };
    statix.enable = true;
    shellcheck.enable = true;
    shfmt.enable = true;
  };
  settings = {
    global.excludes = ["bin/*" ".editorconfig" "*/ssh/*"];
    formatter.shfmt.priority = 1;
  };
}
