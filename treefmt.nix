_: {
  projectRootFile = ".git/config";
  programs = {
    alejandra.enable = true;
    statix.enable = true;
  };
  settings = {
    global.excludes = ["bin/*" ".editorconfig" "*/ssh/*"];
  };
}
