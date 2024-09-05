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
    # Helpers for producing system-specific outputs
    forEachSystem = supportedSystems: f:
      nixpkgs.lib.genAttrs supportedSystems (
        system:
          f {
            pkgs = import nixpkgs {
              inherit system;
              config.allowUnfree = true;
            };
          }
      );
  in {
    # Schemas tell Nix about the structure of your flake's outputs
    inherit (flake-schemas) schemas;

    legacyPackages = let
      username = "mohammed";

      # Define supported systems
      allSystems = [
        "aarch64-darwin"
        "x86_64-darwin"
        "aarch64-linux"
        "x86_64-linux"
      ];

      # Partially apply the system list
      forAllSystems = forEachSystem allSystems;
    in
      forAllSystems ({pkgs}: rec {
        default = homeConfigurations.${username};
        homeConfigurations.${username} = home-manager.lib.homeManagerConfiguration {
          # inherit (pkgs) system;
          inherit pkgs;
          extraSpecialArgs = {inherit inputs username;};
          # Specify your home configuration modules here, for example,
          # the path to your home.nix.
          modules = [
            ./home.nix
            catppuccin.homeManagerModules.catppuccin
          ];
        };
      });

    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "aarch64-linux";
      modules = [./configuration.nix];
    };
  };
}
