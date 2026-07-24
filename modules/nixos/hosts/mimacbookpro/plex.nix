{
  pkgs,
  username,
  ...
}: let
  # Pinned version of Plex Media Server
  #
  # ---
  # refs:
  # - https://www.plex.tv/media-server-downloads/?cat=computer&plat=linux
  version = "1.43.3.10828-00f62d37d";

  # Version's SHA-1 Checksum: d73eba8f297785e1b611ed6e1628b2432eaa617e
  #
  # Verfiy hash with:
  # ```
  # nix-prefetch-url --type sha1 "${url}" "${sha1_hash}"
  # ```
  #
  # Get SHA-256 checksum with:
  # ```
  # read -r hash < <(nix-prefetch-url "${url}") &&
  #   nix-hash --to-sri --type sha256 "${hash}"
  # ```
  plexRaw = pkgs.plexRaw.overrideAttrs (_: {
    inherit version;
    src = pkgs.fetchurl {
      url =
        "https://downloads.plex.tv/plex-media-server-new/${version}/"
        + "debian/plexmediaserver_${version}_amd64.deb";
      hash = "sha256-ieU0/7Vlrs2tsR1QhD2Cyk/pia4MfmAugx0Ec6Ook20=";
    };
  });
in {
  services = {
    plex = {
      enable = true;
      openFirewall = true;
      dataDir = "/persistent/var/lib/plex";
      package = pkgs.plex.override {inherit plexRaw;};
    };
    tailscale.serve.services.plex.endpoints = {
      "tcp:443" = "https+insecure://127.0.0.1:32400";
    };
  };

  users.users.${username}.extraGroups = ["plex"];
}
