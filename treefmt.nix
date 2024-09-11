_: {
  projectRootFile = ".git/config";
  programs = {
    alejandra.enable = true;
    statix.enable = true;
    shellcheck.enable = true;
    shfmt.enable = true;
  };
  settings = {
    global.excludes = ["bin/*" ".editorconfig" "*/ssh/*"];
    formatter.shfmt.priority = 1;
  };
}
