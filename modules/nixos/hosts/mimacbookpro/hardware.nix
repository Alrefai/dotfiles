{
  config,
  lib,
  ...
}: {
  boot = {
    initrd.availableKernelModules = [
      "uhci_hcd"
      "ehci_pci"
      "ahci"
      "firewire_ohci"
      "uas"
      "usbhid"
      "sd_mod"
      "sr_mod"
      "sdhci_pci"

      # Make network card available for remotely unlocking LUKS encrypted root
      # partition during boot process.
      #
      # ```
      # lspci -v | grep -iA8 'network\|ethernet'
      # ```
      #
      # ---
      # refs:
      # - https://wiki.nixos.org/wiki/Remote_disk_unlocking
      # - https://wiki.archlinux.org/title/Systemd-networkd
      "tg3"
    ];
    kernelModules = ["kvm-intel"];
  };

  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware
    .enableRedistributableFirmware;
}
