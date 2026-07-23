{
  device,
  swap,
  ...
}: {
  boot.zswap = {
    enable = true;
    maxPoolPercent = 50;
  };

  disko.devices = {
    disk.main = {
      type = "disk";
      inherit device;
      content = {
        type = "gpt";
        partitions = {
          ESP = {
            size = "1G";
            type = "EF00";
            label = "esp";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = ["umask=0077"];
            };
          };
          LUKS = {
            size = "100%";
            label = "nixos";
            content = {
              type = "luks";
              name = "crypted--system";
              passwordFile = "/tmp/luks.key"; # Password for initial encryption
              settings.allowDiscards = true; # TRIM through LUKS (SSDs)
              extraOpenArgs = ["--tries 5"];
              content = {
                type = "btrfs";
                extraArgs = ["-f"];
                subvolumes = {
                  "/log" = {
                    mountpoint = "/var/log";
                    mountOptions = ["compress=zstd" "noatime"];
                  };
                  "/nix" = {
                    mountpoint = "/nix";
                    mountOptions = ["compress=zstd" "noatime"];
                  };
                  "/persistent" = {
                    mountpoint = "/persistent";
                    mountOptions = ["compress=zstd" "noatime"];
                  };
                  "/swap" = {
                    mountpoint = "/.swapvol";
                    mountOptions = [
                      # Enabling TRIM (discard) on the swap files can help avoid
                      # unnecessary copy actions on the SSD, reducing wear and
                      # potentially helping increase performance.
                      #
                      # ---
                      # refs:
                      # - https://wiki.nixos.org/wiki/Swap#discard
                      "discard"
                      "noatime"
                    ];
                    swap.swapfile.size = swap;
                  };
                };
              };
            };
          };
        };
      };
    };

    nodev."/" = {
      device = "tmpfs";
      fsType = "tmpfs";
      mountOptions = ["size=25%" "mode=755"];
    };
  };

  fileSystems = {
    "/persistent".neededForBoot = true;
    "/var/log".neededForBoot = true;
  };

  services.btrfs.autoScrub = {
    enable = true;
    interval = "weekly";
    fileSystems = ["/"];
  };
}
