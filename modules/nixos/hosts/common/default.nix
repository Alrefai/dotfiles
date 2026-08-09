# Common system packages and programs
{
  lib,
  modulesPath,
  username,
  ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
    ./disk.nix
    ./networks.nix
    ./preservation.nix
    ./services.nix
    ./tailscale.nix
  ];

  boot = {
    # Use the systemd-boot EFI boot loader.
    loader = {
      systemd-boot = {
        enable = true;
        editor = false;
        bootCounting.enable = true;
        configurationLimit = lib.mkDefault 5;
      };
      efi.canTouchEfiVariables = true;
    };
    /**
    Limit the verbosity of the system to a strict minimum and hide any kernel
    messages from the console.

    ---
    refs:
    - https://wiki.archlinux.org/title/Silent_boot
    */
    kernel.sysctl = {
      "kernel.printk" = "3 3 3 3";
    };
    kernelParams = [
      "quiet"
      "loglevel=3"
      "systemd.show_status=auto"
      "rd.udev.log_level=3"
    ];
  };

  # Configure console keymap
  console.keyMap = "uk";

  # Enable 'sudo' with SSH key
  security.pam.sshAgentAuth.enable = true;

  systemd = {
    sleep.settings.Sleep = lib.mkDefault {
      AllowSuspend = "no";
      AllowHibernation = "no";
      AllowHybridSleep = "no";
      AllowSuspendThenHibernate = "no";
    };
  };

  users.users.${username} = {
    isNormalUser = true;
    hashedPasswordFile = "/persistent/secrets/passwords/${username}";
    linger = lib.mkDefault true;
    uid = lib.mkDefault 1000;
  };
}
