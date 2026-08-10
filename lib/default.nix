{lib, ...} @ inputs: let
  importModules = dir: args: let
    inherit (lib) foldl' hasSuffix pipe;

    modules = pipe (builtins.readDir dir) [
      builtins.attrNames
      (builtins.filter (hasSuffix ".nix"))
      (builtins.filter (name: name != "default.nix"))
    ];

    importModule = name: import (dir + "/${name}") args;
  in
    foldl' (modules: name: modules // importModule name) {} modules;

  helpers = importModules ./. (inputs // {inherit lib;});
in
  helpers // {inherit importModules;}
