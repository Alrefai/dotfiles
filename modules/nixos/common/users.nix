# User configuration
{ pkgs, ... }:
{
  users = {
    defaultUserShell = pkgs.zsh;
    extraUsers.mohammed = {
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