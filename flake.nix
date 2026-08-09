{
  description = ''
    Multi-platform Nix configuration with home-manager (standalone), nix-darwin,
    and NixOS support
  '';
  # FORK: To use this configuration, replace "mohammed" with your username
  # throughout this file

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-26_05-darwin.url = "github:nixos/nixpkgs/nixpkgs-26.05-darwin";

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-darwin-x86_64 = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs-26_05-darwin";
    };

    nixos-hardware = {
      url = "github:nixos/nixos-hardware";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    deploy-rs.url = "github:serokell/deploy-rs";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    preservation.url = "github:nix-community/preservation";

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
    nixpkgs-26_05-darwin,
    systems,
    nix-darwin,
    nix-darwin-x86_64,
    nixos-hardware,
    deploy-rs,
    disko,
    preservation,
    treefmt-nix,
    home-manager,
    catppuccin,
    ...
  } @ inputs: let
    # Eval the treefmt modules from ./treefmt.nix
    treefmtEval = pkgs: (treefmt-nix.lib.evalModule pkgs ./treefmt.nix)
      .config.build;

    /**
    refs:
    - https://github.com/serokell/deploy-rs#overall-usage
    - https://github.com/serokell/deploy-rs/issues/163#issuecomment-2991603313
    */
    deploy-rsOverlay = final: prev: let
      defaultOverlays = deploy-rs.overlays.default final prev;
    in {
      deploy-rs = {
        inherit (prev) deploy-rs;
        inherit (defaultOverlays.deploy-rs) lib;
      };
    };

    devToolsOverlay = final: prev: {
      devTools = let
        treefmtEvalPlatform = treefmtEval final;
      in {
        # Make the treefmt command available in the shell using the specified
        # configuration in `./treefmt.nix`.
        treefmt = treefmtEvalPlatform.wrapper;
        # Get access to the individual programs from treefmt, which could be
        # useful to provide them to your IDE or editor.
        inherit
          (treefmtEvalPlatform.programs)
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
      nixpkgs.lib.genAttrs supportedSystems (system: let
        nixpkgsSource =
          if system == "x86_64-darwin"
          then nixpkgs-26_05-darwin
          else nixpkgs;
      in
        generateConfig {
          pkgs = import nixpkgsSource {
            inherit system;
            config = {
              allowUnfree = true;
              allowDeprecatedx86_64Darwin =
                nixpkgs.lib.mkIf (system == "x86_64-darwin") true;
            };
            overlays = [deploy-rsOverlay devToolsOverlay];
          };
        });

    # Partially apply the system list to `forEachSystem` function
    forAllSystems = forEachSystem (import systems);

    # Set my personal data for all systems
    username = "mohammed";
    name = "Mohammed Alrefai";
    email = "mohammed" + "@" + "refam.io";

    # Hosts declaration
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
    formatter = forAllSystems ({pkgs}: (treefmtEval pkgs).wrapper);

    # for `nix flake check`
    checks = forAllSystems ({pkgs}:
      {formatting = (treefmtEval pkgs).check self;}
      // pkgs.deploy-rs.lib.deployChecks self.deploy);

    packages = forAllSystems ({pkgs}: {
      inherit (pkgs.deploy-rs) deploy-rs;
    });

    apps = forAllSystems ({pkgs}: {
      deploy = {
        type = "app";
        program = nixpkgs.lib.getExe (pkgs.writeShellApplication {
          name = "deploy";
          runtimeInputs = builtins.attrValues {
            inherit (pkgs.deploy-rs) deploy-rs;
            inherit (pkgs) git;
          };
          text = ''
            read -r BRANCH < <(git branch --show-current)
            read -r COMMIT < <(git rev-parse --short HEAD)
            read -r TIMESTAMP < <(date '+%Y.%m.%dT%H:%M')

            exec env NIXOS_LABEL="build_$BRANCH:$COMMIT:$TIMESTAMP" deploy "$@"
          '';
        });
      };
    });

    deploy = let
      activate = forAllSystems ({pkgs}: pkgs.deploy-rs.lib.activate);
      getHostConfig = hostname: rec {
        hostConfig = self.nixosConfigurations.${hostname};
        system = hostConfig.config.nixpkgs.hostPlatform.system;
      };
    in {
      activationTimeout = 600;
      confirmTimeout = 60;
      fastConnection = true;
      sshOpts = ["-o" "SendEnv=NIXOS_LABEL"];
      user = "root";
      nodes = {
        mimacbookpro = rec {
          hostname = "mimacbookpro";
          profiles.system = let
            inherit (getHostConfig hostname) hostConfig system;
            username = hostConfig.config.users.users.nimda.name;
          in {
            path = activate.${system}.nixos hostConfig;
            sshUser = username;
          };
        };
      };
    };

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
              extraSpecialArgs = {inherit inputs username name email;};
            };
        in
          nixpkgs.lib.mapAttrs mkHomeConfigProfile profiles;
      };
    in
      # Make configurations for all supported systems for the provided username
      forAllSystems (mkHomeConfig username);

    #*** nixos configurations ***#
    nixosConfigurations = let
      hosts = {
        nixos = {
          system = "aarch64-linux";
          role = "developmentVM";
          isVM = true;
          # Uses OrbStack-managed /etc/nixos/configuration.nix
          extraModules = [/etc/nixos/configuration.nix];
        };
        mimacbookpro = {
          username = "nimda";
          system = "x86_64-linux";
          hardware = "apple-macbook-pro-8-1";
          role = "nixos-server";
          ethernetPCI = "pci-0000:02:00.0";
          gateway = "192.168.86.1";
          ip = "192.168.86.200";
          swap = "16G";
          device =
            "/dev/disk/by-id/"
            # Main disk only.
            # Additional disks are configured in the host's directory
            + "ata-Samsung_SSD_850_EVO_250GB_S21NNSAFC77623K";
          dataDisksMountpointSuffix = "data"; # without leading index
        };
      };

      # Helper function to create a NixOS system configuration
      mkNixOSHost = hostname: {extraModules ? [], ...} @ args:
        nixpkgs.lib.nixosSystem {
          specialArgs =
            args
            // {
              inherit hostname email;
              username = args.username or username;
            };

          modules =
            [./modules/common ./modules/nixos/common]
            ++ extraModules
            ++ nixpkgs.lib.optionals (!args.isVM or false) [
              (nixos-hardware.nixosModules.${args.hardware} or {})
              disko.nixosModules.disko
              preservation.nixosModules.default
              ./modules/nixos/hosts/common
              ./modules/nixos/hosts/${hostname}
            ];
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
          extraModules = [./modules/darwin/hosts/mimac];
          extraSpecialArgs = {
            inherit email;
            machineRole = mimac.role;
          };
        };

        ${mim2macbookair.name} = {
          extraModules = [
            {
              homebrew.casks = ["kindavim" "transmit"];
              networking.knownNetworkServices = ["USB 10/100/1000 LAN"];
            }
          ];
          extraSpecialArgs = {machineRole = mim2macbookair.role;};
        };
      };

      # Helper function to create a Darwin system configuration
      mkDarwinHost = hostname: hostConfig: let
        # Merge host config with defaults
        config = defaults // hostConfig // {inherit hostname;};
        nix-darwinSource =
          if config.system == "x86_64-darwin"
          then nix-darwin-x86_64
          else nix-darwin;
      in
        nix-darwinSource.lib.darwinSystem {
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
