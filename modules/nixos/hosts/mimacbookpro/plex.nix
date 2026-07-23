{username, ...}: {
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
