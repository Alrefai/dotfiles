{lib, ...} @ inputs: let
  importModules = dir: args: let
    inherit (lib) attrNames filter foldl' hasSuffix pipe readDir removeSuffix;

    modules = pipe (readDir dir) [
      attrNames
      (filter (hasSuffix ".nix"))
      (filter (name: name != "default.nix"))
      (map (removeSuffix ".nix"))
    ];

    importModule = name: {${name} = import (dir + "/${name}.nix") args;};
  in
    foldl' (acc: name: acc // importModule name) {} modules;

  helpers = importModules ./. (inputs // {inherit lib;});
in
  helpers // {inherit importModules;}
