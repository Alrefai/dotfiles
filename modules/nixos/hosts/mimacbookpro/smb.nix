{
  config,
  pkgs,
  username,
  ...
}: {
  environment.systemPackages = [pkgs.cifs-utils];

  fileSystems."/mnt/remote/mimac-smb/media" = {
    device = "//192.168.86.99/midrobo/media";
    fsType = "cifs";
    options = let
      uid = config.users.users.${username}.uid or 1000;
      gid = config.users.users.plex.group or 1;
    in [
      "_netdev,noauto,nofail"
      "credentials=/persistent/secrets/smb/mimac"
      "file_mode=0440,dir_mode=0550,ro"
      "uid=${toString uid},gid=${toString gid}"
      "x-systemd.automount"
      "x-systemd.device-timeout=5"
      "x-systemd.idle-timeout=60"
      "x-systemd.mount-timeout=5"
    ];
  };
}
