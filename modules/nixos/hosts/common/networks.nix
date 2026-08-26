{
  config,
  ethernetPCI,
  gateway,
  hostname,
  ip,
  username,
  ...
}: {
  boot = {
    initrd = {
      systemd = {
        enable = true;
        users.root.shell = "/bin/systemd-tty-ask-password-agent";
        inherit (config.systemd) network;
      };

      network.ssh = {
        enable = true;
        # WARNING: This private ssh key will not be encrypted on the disk.
        #
        # Unless your bootloader supports initrd secrets, these keys
        # are stored insecurely in the global Nix store. Do NOT use
        # your regular SSH host private keys for this purpose or
        # you'll expose them to regular users!
        #
        # Additionally, even if your initrd supports secrets, if
        # you're using initrd SSH to unlock an encrypted disk then
        # using your regular host keys exposes the private keys on
        # your unencrypted boot partition.
        hostKeys = ["/persistent/secrets/ssh/initrd/ssh_host_ed25519_key"];
        authorizedKeys = config.users.users.${username}.openssh
          .authorizedKeys.keys;
      };
    };
  };

  networking = {
    hostName = hostname;
    useDHCP = false;
  };

  systemd = {
    network = let
      ethernetName = "10-lan";
    in {
      enable = true;
      networks = {
        "${ethernetName}" = {
          # nix shell nixpkgs#pciutils -c lspci -D | grep 'Ethernet'
          matchConfig.Path = ethernetPCI;
          address = ["${ip}/24"];
          routes = [{Gateway = gateway;}];
        };
      };
      links."${ethernetName}" = {
        inherit
          (config.systemd.network.networks."${ethernetName}")
          matchConfig
          ;
        linkConfig.Name = "eth0";
      };
    };
  };
}
