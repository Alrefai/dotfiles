# User configuration
{ pkgs, username, ... }:
{
  users = {
    defaultUserShell = pkgs.zsh;
    extraUsers.${username} = {
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
  };

  # Enable zsh
  programs.zsh.enable = true;
}