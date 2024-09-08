{
  description = "Home Manager configuration of mohammed";

  inputs = {
    flake-schemas.url = "https://flakehub.com/f/DeterminateSystems/flake-schemas/*.tar.gz";

    nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0.1.0.tar.gz";

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
    flake-schemas,
    nixpkgs,
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

    # A higher-order function to generate home-manager configurations for
    # given username and system
    generateHomeConfigurations = username: {pkgs}: {
      # Define the home-manager configuration for the defined user
      homeConfigurations = {
        ${username} = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          # Pass arguments to the configuration modules
          extraSpecialArgs = {inherit inputs username;};
          # List of configuration modules to include
          modules = [
            ./home.nix
            catppuccin.homeManagerModules.catppuccin
          ];
        };
      };
    };

    # List of supported systems/architectures
    allSystems = [
      "aarch64-darwin"
      "x86_64-darwin"
      "aarch64-linux"
      "x86_64-linux"
    ];

    # Partially apply the system list to `forEachSystem` function
    forAllSystems = forEachSystem allSystems;

    # Apply the configuration generator to all supported systems
    # for the provided username
    homeConfigsForAllSystems = forAllSystems (
      generateHomeConfigurations "mohammed"
    );
  in {
    # Schemas tell Nix about the structure of your flake's outputs
    inherit (flake-schemas) schemas;

    #*** home-manager configurations ***#
    legacyPackages = homeConfigsForAllSystems;

    #*** nixos configurations ***#
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "aarch64-linux";
      modules = [./configuration.nix];
    };
  };
}
