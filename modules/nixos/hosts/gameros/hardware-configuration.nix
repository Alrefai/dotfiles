{
  config,
  lib,
  modulesPath,
  ...
}: {
  imports = [
    (modulesPath + "/hardware/network/broadcom-43xx.nix")
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot = {
    initrd = {
      availableKernelModules = [
        # iMac 18,3 and 12,1
        "ahci"
        "sd_mod"
        "uas"
        "usb_storage"
        "usbhid"

        # iMac 18,3 only
        "nvme"
        "sdhci_pci"
        "xhci_pci"

        # iMac 12,1 only
        "ehci_pci"
        "sr_mod"
        "uhci_hcd"
      ];
      kernelModules = [];
      luks.devices."nixos" = {
        device = "/dev/disk/by-uuid/92e7078e-6205-46a1-be65-61ee00d2f08b";
      };
    };
    kernelModules = ["kvm-intel"];
    extraModulePackages = [];
  };

  fileSystems = let
    volumes = {
      "/" = {name = "root";};
      "/home" = {name = "home";};
      "/nix" = {name = "nix";};
      "/persist" = {
        name = "persist";
        neededForBoot = true;
      };
      "/var/log" = {
        name = "log";
        neededForBoot = true;
      };
      "/swap" = {name = "swap";};
    };

    mkFileSystem = volume: volumeConfig: {
      device = "/dev/mapper/nixos";
      fsType = "btrfs";
      options = ["subvol=${volumeConfig.name}" "compress=zstd" "noatime"];
      neededForBoot = volumeConfig.neededForBoot or false;
    };
  in
    {
      "/boot" = {
        device = "/dev/disk/by-uuid/12CE-A600";
        fsType = "vfat";
        options = ["umask=077"];
      };
    }
    // lib.mapAttrs mkFileSystem volumes;

  swapDevices = [{device = "/swap/swapfile";}];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
