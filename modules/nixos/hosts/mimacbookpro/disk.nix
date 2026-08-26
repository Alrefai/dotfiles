/**
Check the reported logical and physical sector sizes of storage devices with:
`lsblk -td`

To determine if the sector size of an Advanced Format hard disk drive can be
changed, use the hdparm utility: `hdparm -I /dev/sdX | grep 'Sector size:'`

---
refs:
- https://wiki.archlinux.org/title/Advanced_Format
- https://docs.rustfs.com/installation/linux/prerequisites-and-service
*/
{
  config,
  dataDisksMountpointSuffix,
  lib,
  ...
}: let
  disks = [
    {
      advancedFormat = true; # 512e
      device = "ata-HGST_HTS541010A9E680_161122JD10424A305DWS";
      # destroy = true;
      _meta = {
        logicalSectorSize = 512;
        physicalSectorSize = 4096;
      };
    }
    {
      advancedFormat = true; # 512e
      device = "ata-ST1000VM002-1CT162_W1G0GL5Y";
      # destroy = true;
      _meta = {
        logicalSectorSize = 512;
        physicalSectorSize = 4096;
      };
    }
    {
      advancedFormat = false; # 512n
      device = "usb-WD_My_Book_Duo_0A10_575541323733313030393735-0:0";
      # destroy = true;
      _meta = {
        logicalSectorSize = 512;
        physicalSectorSize = 512;
      };
    }
    {
      advancedFormat = false; # 512n
      device = "usb-WD_My_Book_Duo_0A10_575541323733313030393735-0:1";
      # destroy = true;
      _meta = {
        logicalSectorSize = 512;
        physicalSectorSize = 512;
      };
    }
  ];

  mkDisk = index: {destroy ? false, ...} @ inputs: let
    fixedWidthIndex = "${lib.fixedWidthNumber 2 index}";
    name = dataDisksMountpointSuffix + fixedWidthIndex;
    device = "/dev/disk/by-id/" + inputs.device;
  in {
    inherit name;
    value = {
      inherit name device destroy;
      type = "disk";
      content = {
        type = "luks";
        name = "crypted-${name}";
        /**
        Postpone unlocking until stage 2 boot with crypttab
        */
        initrdUnlock = false;
        passwordFile = "/tmp/luks.key"; # Password for initial encryption
        extraFormatArgs =
          ["--label" "LUKS-${lib.strings.toSentenceCase name}"]
          ++ lib.optionals inputs.advancedFormat ["--sector-size" "4096"];
        content = {
          type = "filesystem";
          format = "xfs";
          /**
          WARNING:
          The "-f" flag will force format the disk even if "destory = false;".
          To avoid this, "-f" flag must be set conditionally.

          */
          extraArgs =
            ["-L" "RustFS${fixedWidthIndex}"]
            ++ lib.optionals destroy ["-f"];
          mountOptions = [
            /**
            For metadata-heavy workloads (which object stores often are),
            increasing the log buffer (`logbsize`) can improve throughput.
            */
            "lazytime,noatime,noauto,nofail,logbsize=256k"
            # Infinity timout for unlocking LUKS; will timeout with device
            "x-systemd.device-timeout=0"
            "x-systemd.requires-mounts-for=/boot"
          ];
          mountpoint = "/mnt/hdd/rustfs/${name}";
        };
      };
    };
  };
in {
  disko.devices.disk = builtins.listToAttrs (lib.lists.imap1 mkDisk disks);

  environment.etc.crypttab.text = let
    isDataDisk = key: _: lib.hasPrefix dataDisksMountpointSuffix key;

    crypttabEntry = _: disk:
      builtins.concatStringsSep " " [
        disk.content.name
        disk.content.device
        /**
        No key file required for LUKS.
        Decryption is handled by crypttab using main disk's passphrase.

        NOTE: You must use the same passphrase for all LUKS disks in this case.

        */
        "none"
        "luks,noauto,nofail,x-systemd.device-timeout=10"
      ];

    crypttab = lib.pipe config.disko.devices.disk [
      (lib.filterAttrs isDataDisk)
      (lib.mapAttrsToList crypttabEntry)
      (builtins.sort builtins.lessThan)
      (builtins.concatStringsSep "\n")
    ];
  in
    crypttab;

  /**
  Disable fsck on journaling filesystems such as xfs.

  `fsck.xfs` is called by the generic Linux fsck(8) program at startup to check
  and repair an XFS filesystem. XFS is a journaling filesystem and performs
  recovery at mount(8) time if necessary, so `fsck.xfs` simply exits with a zero
  exit status.

  If you wish to check the consistency of an XFS filesystem, or repair a damaged
  or corrupt XFS filesystem, see xfs_repair(8).

  NOTE:
  Although an `fsck.xfs` binary is present in the `xfsprogs` package, this is
  present only to satisfy initscripts that look for an `fsck.file` system binary
  at boot time. `fsck.xfs` immediately exits with an exit code of `0`.

  ---
  refs:
  - https://man7.org/linux/man-pages/man8/fsck.xfs.8.html
  - https://man7.org/linux/man-pages/man8/xfs_repair.8.html
  */
  boot.initrd.checkJournalingFS = lib.mkDefault false;
}
