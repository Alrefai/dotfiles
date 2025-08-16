# Host-specific configuration for the 'nixos' machine
{...}: {
  imports = [
    # Keep OrbStack-managed configuration as the base
    /etc/nixos/configuration.nix
    # Add MCP configuration on top
    ./mcp
  ];

  # Enable MCP servers
  services.mcp-servers.enable = true;
}
