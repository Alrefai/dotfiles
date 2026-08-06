/**
# Pinned version of Plex Media Server

Version's SHA-1 Checksum: 02011c3275c67c0c73e170031187972d421b9fc9

Verfiy hash with:

```
nix-prefetch-url --type sha1 "${url}" "${sha1_hash}"
```

Get SHA-256 checksum with:

```
read -r hash < <(nix-prefetch-url "${url}") &&
  nix-hash --to-sri --type sha256 "${hash}"
```

---
refs:
- https://www.plex.tv/media-server-downloads/?cat=computer&plat=linux
*/
{username, ...}: let
  plexOverlay = final: prev: {
    plex = prev.plex.override {
      plexRaw = prev.plexRaw.overrideAttrs rec {
        version = "1.43.3.10861-07dfddaeb";
        src = final.fetchurl {
          url =
            "https://downloads.plex.tv/plex-media-server-new/${version}/"
            + "debian/plexmediaserver_${version}_amd64.deb";
          hash = "sha256-s8OpELTLfdincYQZawp76rsZx5AQXMR6+algH/Ev0zI=";
        };
      };
    };
  };
in {
  nixpkgs.overlays = [plexOverlay];

  services = {
    plex = {
      enable = true;
      openFirewall = true;
      dataDir = "/persistent/var/lib/plex";
    };
    tailscale.serve.services.plex.endpoints = {
      "tcp:443" = "https+insecure://127.0.0.1:32400";
    };
  };

  users.users.${username}.extraGroups = ["plex"];
}
