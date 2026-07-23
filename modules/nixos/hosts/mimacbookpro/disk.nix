_: {
  disko.devices = {
    disk.data01 = {
      type = "disk";
      device = "/dev/disk/by-id/ata-HGST_HTS541010A9E680_161122JD10424A305DWS";
      name = "data01";
      destroy = false;
      content = {
        type = "luks";
        name = "crypted-data01";
        passwordFile = "/tmp/luks.key"; # Password for initial encryption
        extraOpenArgs = ["--tries 5"];
        content = {
          type = "filesystem";
          format = "xfs";
          extraArgs = [
            "-L"
            "data01_01tb"
            "-d"
            "su=256k,sw=10"
            "-i"
            "maxpct=0"
          ];
          mountOptions = [
            "defaults"
            "logbsize=256k"
            "noatime"
            "nodiratime"
            "nofail"
            "x-systemd.device-timeout=0"
          ];
          mountpoint = "/mnt/hdd/data01-01tb";
        };
      };
    };
  };
}
