# Common services configuration
_: {
  services.tailscale.enable = true;

  # Enable common container config files in /etc/containers
  virtualisation = {
    containers.enable = true;
    oci-containers.backend = "podman";
    podman = {
      enable = true;

      # Periodically prune Podman resources weekly
      autoPrune.enable = true;

      # Create a `docker` alias for podman, to use it as a drop-in replacement
      dockerCompat = true;

      # Make the Podman socket available in place of the Docker socket,
      # so Docker tools can find the Podman socket.
      dockerSocket.enable = true;

      # Required for containers under podman-compose to be able to talk to each other.
      defaultNetwork.settings.dns_enabled = true;
    };
  };
}
