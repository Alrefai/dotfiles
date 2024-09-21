{
  description = "Home Manager configuration of mohammed";

  inputs = {
    flake-schemas.url = "https://flakehub.com/f/DeterminateSystems/flake-schemas/*.tar.gz";

    nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0.1.0.tar.gz";

    lix-module = {
      url = "https://git.lix.systems/lix-project/nixos-module/archive/2.91.0.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "https://flakehub.com/f/nix-community/home-manager/0.1.0.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    catppuccin.url = "https://flakehub.com/f/catppuccin/nix/1.0.*.tar.gz";

    #*** Non-flake source code ***#
    # forked from nvim-lua/kickstart.nvim
    minvim = {
      url = "github:alrefai/minvim/config";
      flake = false;
    };
    # forked from gpakosz/.tmux
    mitmux = {
      url = "github:alrefai/mitmux/config";
      flake = false;
    };
    # yazi plugins
    yazi-plugins = {
      url = "github:yazi-rs/plugins";
      flake = false;
    };
    # starship prompt yazi plugin
    starship-yazi = {
      url = "github:Rolv-Apneseth/starship.yazi";
      flake = false;
    };
  };

  outputs = {
    self,
    flake-schemas,
    nixpkgs,
    systems,
    lix-module,
    treefmt-nix,
    home-manager,
    catppuccin,
    ...
  } @ inputs: let
    # A higher-order helper function that generates system-specific
    # outputs
    forEachSystem = supportedSystems: generateConfig:
      nixpkgs.lib.genAttrs supportedSystems (
        system:
          generateConfig {
            pkgs = import nixpkgs {
              inherit system;
              config.allowUnfree = true;
            };
          }
      );

    # Partially apply the system list to `forEachSystem` function
    forAllSystems = forEachSystem (import systems);

    # Eval the treefmt modules from ./treefmt.nix
    treefmtEval = forAllSystems (
      {pkgs}: treefmt-nix.lib.evalModule pkgs ./treefmt.nix
    );

    # A higher-order function to generate home-manager configurations for
    # given username and system
    generateHomeConfigurations = username: {pkgs}: {
      # Define the home-manager configuration for the defined user
      homeConfigurations = let
        treefmtEvalPlatform = treefmtEval.${pkgs.system};
        # Make the treefmt command available in the shell using the specified
        # configuration in `./treefmt.nix`.
        treefmt = treefmtEvalPlatform.config.build.wrapper;
        # Get access to the individual programs from treefmt, which could be
        # useful to provide them to your IDE or editor.
        inherit
          (treefmtEvalPlatform.config.build.programs)
          alejandra # nix formatter
          dprint # code formatter
          shellcheck # sh linter
          shfmt # sh formatter
          statix # nix linter
          ;
      in {
        ${username} = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          # Pass arguments to the configuration modules
          extraSpecialArgs = {
            inherit
              inputs
              username
              alejandra
              dprint
              shellcheck
              shfmt
              statix
              treefmt
              ;
          };
          # List of configuration modules to include
          modules = [
            ./home.nix
            catppuccin.homeManagerModules.catppuccin
          ];
        };
      };
    };

    # Apply the configuration generator to all supported systems
    # for the provided username
    homeConfigsForAllSystems = forAllSystems (
      generateHomeConfigurations "mohammed"
    );
  in {
    # Schemas tell Nix about the structure of your flake's outputs
    inherit (flake-schemas) schemas;

    # for `nix fmt`
    formatter = forAllSystems (
      {pkgs}: treefmtEval.${pkgs.system}.config.build.wrapper
    );

    # for `nix flake check`
    checks = forAllSystems ({pkgs}: {
      formatting = treefmtEval.${pkgs.system}.config.build.check self;
    });

    #*** home-manager configurations ***#
    legacyPackages = homeConfigsForAllSystems;

    #*** nixos configurations ***#
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "aarch64-linux";
      modules = [./configuration.nix lix-module.nixosModules.default];
    };
  };
}
