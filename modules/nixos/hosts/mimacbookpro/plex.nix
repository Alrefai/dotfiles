/**
# Pinned version of Plex Media Server

Version's SHA-1 Checksum: 3c6a6b6e348f373bd9eaeaaaa533b8cf1ade5212

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
        version = "1.43.3.10896-cb3ebc72d";
        src = final.fetchurl {
          url =
            "https://downloads.plex.tv/plex-media-server-new/${version}/"
            + "debian/plexmediaserver_${version}_amd64.deb";
          hash = "sha256-qgnyZt3PQI4Qz3ulYbbkVObhCbqUFjlraWW9THnzcUk=";
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
