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
  };

  # Configure console keymap
  console.keyMap = "uk";

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
