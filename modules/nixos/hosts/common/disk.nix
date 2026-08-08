{
  device,
  lib,
  swap,
  ...
}: {
  boot.zswap = {
    enable = true;
    maxPoolPercent = 50;
  };

  disko.devices = {
    disk.main = rec {
      inherit device;
      type = "disk";
      destroy = false;
      content = {
        type = "gpt";
        partitions = {
          ESP = {
            size = "1G";
            type = "EF00";
            label = "ESP"; # EFI System Partition
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = ["umask=0077"];
            };
          };
          LUKS = {
            size = "100%";
            label = "GNU-Linux";
            content = {
              type = "luks";
              name = "crypted-system";
              passwordFile = "/tmp/luks.key"; # Password for initial encryption
              settings.allowDiscards = true; # TRIM through LUKS (SSDs)
              extraFormatArgs = ["--label" "LUKS-NixOS"];
              extraOpenArgs = ["--tries" "5"];
              content = {
                type = "btrfs";
                /**
                WARNING:
                The `-f` flag will force format the disk even if
                `destory = false;`. To avoid this, `-f` flag must be set
                conditionally.

                */
                extraArgs =
                  ["-L" "NixOS"]
                  ++ lib.optionals destroy ["-f"];
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
