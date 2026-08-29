{
  email,
  lib,
  pkgs,
  username,
  ...
}: {
  imports = [
    ./croc.nix
    ./disk.nix
    ./hardware.nix
    ./plex.nix
    ./rustfs.nix
    ./smb.nix
  ];

  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [
      "b43-firmware"
      "plexmediaserver"
    ];

  environment.systemPackages =
    builtins.attrValues {
      inherit (pkgs.wrappers) yazi tmux;
    }
    ++ [(lib.hiPrio pkgs.wrappers.zsh)];

  services = {
    tailscale.serve.enable = true;
    tlp.enable = false;
  };

  /**
  WARNING:
  Replace these public keys with your own when you fork this repo.
  They’re only valid for my machine.
  Keys are applied only when the git email matches my identity.

  */
  users.users.${username}.openssh.authorizedKeys.keys = lib
    .mkIf (email == "mohammed" + "@" + "refam.io") [
    (builtins.concatStringsSep " " [
      "ssh-ed25519"
      "AAAAC3NzaC1lZDI1NTE5AAAAIFBh8sQx2EO3OPO85NKlK4IIsF1fFFJ2vpPCpwwuyX6h"
      "@1password"
    ])
  ];

  system.stateVersion = "26.11";
}
