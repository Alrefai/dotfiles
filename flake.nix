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
  };

  outputs = {
    flake-schemas,
    nixpkgs,
    home-manager,
    catppuccin,
    ...
  }: let
    # Helpers for producing system-specific outputs
    supportedSystems = [
      "x86_64-linux"
      "aarch64-darwin"
      "x86_64-darwin"
      "aarch64-linux"
    ];
    forEachSupportedSystem = f:
      nixpkgs.lib.genAttrs supportedSystems (
        system:
          f {
            inherit system;
            pkgs = import nixpkgs {
              inherit system;
              config.allowUnfree = true;
            };
          }
      );
  in {
    # Schemas tell Nix about the structure of your flake's outputs
    schemas = flake-schemas.schemas;

    packages = forEachSupportedSystem ({
      system,
      pkgs,
    }: {
      default = home-manager.defaultPackage.${system};

      homeConfigurations."mohammed" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        # Specify your home configuration modules here, for example,
        # the path to your home.nix.
        modules = [
          ./home.nix
          catppuccin.homeManagerModules.catppuccin
        ];
      };
    });
  };
}
