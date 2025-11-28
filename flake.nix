{
  description = ''
    Multi-platform Nix configuration with home-manager (standalone), nix-darwin,
    and NixOS support
  '';
  # FORK: To use this configuration, replace "mohammed" with your username
  # throughout this file

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
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
      url = "github:alrefai/tmux-network-bandwidth";
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
    nixpkgs,
    systems,
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
        treefmtEvalPlatform = treefmtFor final.stdenv.hostPlatform.system;
      in {
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

    # Hosts declaration
    nixos = {
      name = "nixos";
      system = "aarch64-linux";
      role = "developmentVM";
    };
    mimacbook = {
      name = "mimacbook";
      system = "x86_64-linux";
      role = "legacy";
    };
    mim2macbookair = {
      name = "mim2macbookair";
      system = "aarch64-darwin";
      role = "main";
    };
    mimac = {
      name = "mimac";
      system = "x86_64-darwin";
      role = "mediaServer";
    };
    mimacvm = {
      name = "mimacvm";
      system = "aarch64-darwin";
      role = "experimentalVM";
    };
  in {
    # for `nix fmt`
    formatter = forAllSystems (
      {pkgs}: let
        treefmtEvalPlatform = treefmtFor pkgs.stdenv.hostPlatform.system;
      in
        treefmtEvalPlatform.config.build.wrapper
    );

    # for `nix flake check`
    checks = forAllSystems ({pkgs}: let
      treefmtEvalPlatform = treefmtFor pkgs.stdenv.hostPlatform.system;
    in {
      formatting = treefmtEvalPlatform.config.build.check self;
    });

    #*** home-manager configurations ***#
    legacyPackages = let
      # A higher-order function to generate home-manager configurations for
      # given username and system
      mkHomeConfig = username: {pkgs}: {
        # Define the home-manager configuration for the defined user
        homeConfigurations = let
          defaults = [./modules/home catppuccin.homeModules.catppuccin];

          profiles = {
            ${username} = [];
            "${username}@${mimac.name}" = [./modules/home/media.nix];
            "${username}@${mim2macbookair.name}" = [./modules/home/media.nix];
          };

          mkHomeConfigProfile = _: profileModules:
            home-manager.lib.homeManagerConfiguration {
              inherit pkgs;
              # Merge profile modules with defaults
              modules = defaults ++ profileModules;
              # Pass arguments to the configuration modules
              extraSpecialArgs = {inherit inputs username;};
            };
        in
          nixpkgs.lib.mapAttrs mkHomeConfigProfile profiles;
      };
    in
      # Make configurations for all supported systems for the provided username
      forAllSystems (mkHomeConfig username);

    #*** nixos configurations ***#
    nixosConfigurations = let
      # Default values that can be overridden per-host
      defaults = {
        inherit username;
        system = "aarch64-linux"; # Default system for all VMs
        # Defensive defaults: ensure operations always work, even if host
        # doesn't define these attributes
        extraModules = []; # Ensures concatenation in modules list succeeds
        extraSpecialArgs = {}; # Ensures merge in specialArgs succeeds
      };

      # Host configurations - easy to add new hosts
      hosts = {
        ${nixos.name} = {
          # Inherits all defaults automatically
          # Uses OrbStack-managed /etc/nixos/configuration.nix
          extraModules = [/etc/nixos/configuration.nix];
        };

        ${mimacbook.name} = {
          inherit (mimacbook) system;
          extraModules = [./modules/nixos/hosts/mimacbook/configuration.nix];
        };
      };

      # Helper function to create a NixOS system configuration
      mkNixOSHost = hostname: hostConfig: let
        # Merge host config with defaults
        config = defaults // hostConfig // {inherit hostname;};
      in
        nixpkgs.lib.nixosSystem {
          inherit (config) system;

          specialArgs =
            {
              inherit (config) hostname username;
            }
            // config.extraSpecialArgs;

          modules = [./modules/nixos/common] ++ config.extraModules;
        };
    in
      # Generate configurations for all hosts
      nixpkgs.lib.mapAttrs mkNixOSHost hosts;

    #*** macos configurations ***#
    darwinConfigurations = let
      # Default values that can be overridden per-host
      defaults = {
        inherit username;
        system = "aarch64-darwin"; # Most common for modern Macs
        # Defensive defaults: ensure operations always work, even if host
        # doesn't define these attributes
        extraModules = []; # Ensures concatenation in modules list succeeds
        extraSpecialArgs = {}; # Ensures merge in specialArgs succeeds
      };

      # Host configurations - easy to add new hosts
      hosts = {
        ${mimacvm.name} = {};

        ${mimac.name} = {
          inherit (mimac) system;
          extraModules = [
            {
              homebrew.casks = [
                "drobo-dashboard"
                "font-aref-ruqaa"
                "font-rakkas"
              ];
            }
          ];
          extraSpecialArgs = {machineRole = mimac.role;};
        };

        ${mim2macbookair.name} = {
          extraModules = [{homebrew.casks = ["kindavim" "transmit"];}];
          extraSpecialArgs = {machineRole = mim2macbookair.role;};
        };
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

          modules = [./modules/darwin] ++ config.extraModules;
        };
    in
      # Generate configurations for all hosts
      nixpkgs.lib.mapAttrs mkDarwinHost hosts;
  };
}
