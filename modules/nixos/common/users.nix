# User configuration
{
  config,
  lib,
  pkgs,
  username,
  ...
}: {
  users = {
    defaultUserShell = lib.mkIf config.programs.zsh.enable pkgs.zsh;
    users.${username} = {
      description = lib.strings.toSentenceCase username;
      extraGroups = ["wheel"]; # Enable ‘sudo’ for the user.
      subUidRanges = [
        {
          startUid = 100000;
          count = 65536;
        }
      ];
      subGidRanges = [
        {
          startGid = 100000;
          count = 65536;
        }
      ];
    };
    mutableUsers = lib.mkDefault false;
  };
}
