{
  config,
  pkgs,
  ...
}: let
  user = "gamer";
in {
  system.activationScripts = {
    print-jovian = {
      text = builtins.trace "building the jovian configuration..." "";
    };
  };

  boot.kernelParams = ["amd_pstate=active"];
  # hardware.xone.enable = true;
  jovian.hardware.has.amd.gpu = true;
  jovian.steam = {
    inherit user;
    enable = true;
    desktopSession = config.services.displayManager.defaultSession;
  };

  environment.systemPackages = with pkgs; [
    cmake
    steam-rom-manager
  ];

  services.displayManager.sddm.settings = {
    autologin = {
      inherit user;
      session = "gamescope-wayland.desktop";
    };
  };

  programs = {
    gamemode = {
      enable = true;
      settings = {
        general.renice = 10;
        gpu = {
          apply_gpu_optimisations = "accept-responsibility";
          gpu_device = 0;
          amd_performance_level = "high";
        };
      };
    };
    steam = {
      enable = true;
      localNetworkGameTransfers.openFirewall = true;
    };
  };

  users = {
    groups.${user} = {
      name = user;
      gid = 10000;
    };

    users.${user} = {
      description = user;
      extraGroups = ["gamemode" "networkmanager"];
      group = user;
      home = "/home/${user}";
      isNormalUser = true;
      uid = 10000;
    };
  };
}
