{
  config,
  lib,
  pkgs,
  ...
}: {
  boot = lib.mkIf config.boot.loader.systemd-boot.enable {
    consoleLogLevel = 3;
    initrd = {
      systemd.enable = true;
      verbose = false;
    };

    # Bootloader
    loader = {
      efi.canTouchEfiVariables = true;

      # Limit the number of generations to keep
      systemd-boot.configurationLimit = 5;

      # Hide the OS choice for bootloaders.
      # It's still possible to open the bootloader list by pressing any key
      # It will just not appear on screen unless a key is pressed
      timeout = 0;
    };

    # Use latest kernel.
    kernelPackages = pkgs.linuxPackages_latest;

    # Enable "Silent boot"
    #
    # ---
    # ref:
    # - https://wiki.archlinux.org/title/Silent_boot
    # - https://wiki.archlinux.org/title/Plymouth
    # - https://wiki.nixos.org/wiki/Plymouth
    kernelParams = [
      "quiet" # Disable console messages
      "splash" # Enable splash screen
      "loglevel=3"
      # "intremap=on"
      # "boot.shell_on_fail"
      # "udev.log_priority=3"
      # "rd.systemd.show_status=auto"
      "rd.systemd.show_status=false"
      # "systemd.show_status=false"
      "rd.udev.log_level=3"
      # "plymouth.nolog"
    ];

    plymouth = let
      theme = "seal_2";
    in {
      enable = true;
      inherit theme;
      themePackages = [
        (pkgs.adi1090x-plymouth-themes.override {selected_themes = [theme];})
      ];
      extraConfig = lib.mkDefault "DeviceScale=2";
    };
  };
}
