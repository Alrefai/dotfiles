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
    ./smb.nix
  ];

  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [
      "b43-firmware"
      "plexmediaserver"
    ];

  environment.systemPackages = builtins.attrValues {
    inherit
      (pkgs)
      bottom
      yazi
      ;
  };

  services.tailscale.serve.enable = true;
  services.tlp.enable = false;

  users.users.${username}.openssh.authorizedKeys = {
    #! WARNING:
    #! These public keys are for my machine only.
    #! If you fork this repo, replace them with your own keys.
    #! Keys are applied only when the git email matches my identity.
    keys = lib.mkIf (email == "mohammed" + "@" + "refam.io") [
      (
        "ssh-ed25519 "
        + "AAAAC3NzaC1lZDI1NTE5AAAAIFBh8sQx2EO3OPO85NKlK4IIsF1fFFJ2vpPCpwwuyX6h"
        + " @1password"
      )
    ];
  };

  system.stateVersion = "26.11";
}
