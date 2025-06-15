{
  description = ''
    Multi-platform Nix configuration with home-manager (standalone), nix-darwin,
    and NixOS support
  '';
  # FORK: To use this configuration, replace "mohammed" with your username
  # throughout this file

  inputs = {
    flake-schemas.url = "https://flakehub.com/f/DeterminateSystems/flake-schemas/*.tar.gz";

    nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0.1.0.tar.gz";

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lix-module = {
      url = "https://git.lix.systems/lix-project/nixos-module/archive/2.92.0-3.tar.gz";
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

    catppuccin.url = "github:catppuccin/nix";

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
    # tmux plugin: sessionx
    tmux-sessionx = {
      url = "github:omerxx/tmux-sessionx";
      flake = false;
    };
    # tmux plugin: nerd-font-window-name
    tmux-window-name = {
      url = "github:joshmedeski/tmux-nerd-font-window-name";
      flake = false;
    };
    # tmux plugin: network-bandwidth
    tmux-network-bandwidth = {
      url = "github:alrefai/tmux-network-bandwidth/separator-option";
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
    nix-darwin,
    treefmt-nix,
    home-manager,
    catppuccin,
    ...
  } @ inputs: let
    # Eval the treefmt modules from ./treefmt.nix
    treefmtFor = system:
      treefmt-nix.lib.evalModule nixpkgs.legacyPackages.${system}
      ./treefmt.nix;

    devToolsOverlay = final: prev: {
      devTools = let
        treefmtEvalPlatform = treefmtFor final.system;
      in {
        # Make the treefmt command available in the shell using the specified
        # configuration in `./treefmt.nix`.
        treefmt = treefmtEvalPlatform.config.build.wrapper;
        # Get access to the individual programs from treefmt, which could be
        # useful to provide them to your IDE or editor.
        inherit
          (treefmtEvalPlatform.config.build.programs)
          alejandra # nix formatter
          shellcheck # sh linter
          shfmt # sh formatter
          statix # nix linter
          ;
      };
    };

    # A higher-order helper function that generates system-specific outputs
    forEachSystem = supportedSystems: generateConfig:
      nixpkgs.lib.genAttrs supportedSystems (
        system:
          generateConfig {
            pkgs = import nixpkgs {
              inherit system;
              config.allowUnfree = true;
              overlays = [devToolsOverlay];
            };
          }
      );

    # Partially apply the system list to `forEachSystem` function
    forAllSystems = forEachSystem (import systems);

    # Set the username for all systems
    username = "mohammed";
  in {
    # Schemas tell Nix about the structure of your flake's outputs
    inherit (flake-schemas) schemas;

    # for `nix fmt`
    formatter = forAllSystems (
      {pkgs}: let
        treefmtEvalPlatform = treefmtFor pkgs.system;
      in
        treefmtEvalPlatform.config.build.wrapper
    );

    # for `nix flake check`
    checks = forAllSystems ({pkgs}: let
      treefmtEvalPlatform = treefmtFor pkgs.system;
    in {
      formatting = treefmtEvalPlatform.config.build.check self;
    });

    #*** home-manager configurations ***#
    legacyPackages = let
      # A higher-order function to generate home-manager configurations for
      # given username and system
      mkHomeConfig = username: {pkgs}: {
        # Define the home-manager configuration for the defined user
        homeConfigurations = {
          ${username} = home-manager.lib.homeManagerConfiguration {
            inherit pkgs;
            # Pass arguments to the configuration modules
            extraSpecialArgs = {inherit inputs username;};
            # List of configuration modules to include
            modules = [
              ./home.nix
              catppuccin.homeModules.catppuccin
            ];
          };
        };
      };
    in
      # Make configurations for all supported systems for the provided username
      forAllSystems (mkHomeConfig username);

    #*** nixos configurations ***#
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "aarch64-linux";
      modules = [./configuration.nix lix-module.nixosModules.default];
    };

    #*** macos configurations ***#
    darwinConfigurations = let
      # Default values that can be overridden per-host
      defaults = {
        inherit username;
        system = "aarch64-darwin"; # Most common for modern Macs
        extraModules = [];
        extraSpecialArgs = {};
      };

      # Host configurations - easy to add new hosts
      hosts = {
        mimacvm = {
          # Inherits all defaults automatically
        };

        # Example: Intel Mac with custom settings
        # work-macbook = {
        #   system = "x86_64-darwin";
        #   username = "work-user";
        #   extraModules = [
        #     ./modules/work-specific.nix
        #     ./modules/intel-mac.nix
        #   ];
        #   extraSpecialArgs = {
        #     enableWorkTools = true;
        #   };
        # };

        # Example: M1 Mac mini with minimal config
        # mac-mini = {
        #   extraModules = [
        #     ./modules/headless.nix
        #   ];
        # };
      };

      # Helper function to create a Darwin system configuration
      mkDarwinHost = hostname: hostConfig: let
        # Merge host config with defaults
        config = defaults // hostConfig // {inherit hostname;};
      in
        nix-darwin.lib.darwinSystem {
          specialArgs =
            {
              inherit (config) hostname username system;
            }
            // config.extraSpecialArgs;

          modules =
            [./modules/darwin lix-module.nixosModules.default]
            ++ config.extraModules;
        };
    in
      # Generate configurations for all hosts
      nixpkgs.lib.mapAttrs mkDarwinHost hosts;
  };
}
