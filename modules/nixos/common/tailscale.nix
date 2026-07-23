{config, ...}: {
  # Enable tailscale service and the firewall
  #
  # ---
  # refs:
  # - https://wiki.nixos.org/wiki/Tailscale
  services.tailscale = {
    enable = true;
    disableUpstreamLogging = true;
  };
  networking = {
    nftables.enable = true;
    firewall = {
      enable = true;
      # Always allow traffic from your Tailscale network
      trustedInterfaces = [config.services.tailscale.interfaceName];
      # Allow the Tailscale UDP port through the firewall
      allowedUDPPorts = [config.services.tailscale.port];
    };
  };

  systemd = {
    # Force tailscaled to use nftables (Critical for clean nftables-only systems)
    # This avoids the "iptables-compat" translation layer issues.
    services.tailscaled.serviceConfig.Environment = [
      "TS_DEBUG_FIREWALL_MODE=nftables"
    ];

    # Optimization: Prevent systemd from waiting for network online
    # (Optional but recommended for faster boot with VPNs)
    # network.wait-online.enable = false;
  };
}
