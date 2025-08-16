# Enhanced Security Configuration for MCP Containers
{
  config,
  lib,
  pkgs,
  ...
}: {
  # Create dedicated user for MCP containers
  users.users.mcp-runner = {
    isSystemUser = true;
    group = "mcp-runner";
    uid = 9001;
    description = "MCP container runner";
  };

  users.groups.mcp-runner = {
    gid = 9001;
  };

  # Enhanced security policies for containers
  security = {
    # Audit system for container monitoring
    audit = {
      enable = lib.mkDefault true;
      rules = [
        # Monitor container-related syscalls
        "-a always,exit -F arch=b64 -S clone,unshare,setns -F key=containers"
        "-a always,exit -F arch=b64 -S mount,umount2 -F key=containers"
        # Monitor network activity from containers
        "-a always,exit -F arch=b64 -S socket,connect,bind -F auid>=1000 -F key=network"
      ];
    };
  };

  # Network security for MCP containers
  networking = {
    # Optional firewall rules for MCP containers
    firewall = lib.mkIf config.services.mcp-servers.enableFirewall {
      extraCommands = ''
        # Allow MCP container traffic only on localhost interface
        iptables -A INPUT -i lo -p tcp --dport 8991 -j ACCEPT
        iptables -A INPUT -i lo -p tcp --dport 8992 -j ACCEPT
        iptables -A INPUT -i lo -p tcp --dport 8993 -j ACCEPT
        iptables -A INPUT -s 10.88.0.1 -p tcp --dport 8991 -j ACCEPT
        iptables -A INPUT -s 10.88.0.1 -p tcp --dport 8992 -j ACCEPT
        iptables -A INPUT -s 10.88.0.1 -p tcp --dport 8993 -j ACCEPT

        # Block all other external access to MCP ports
        iptables -A INPUT -p tcp --dport 8991 -j DROP
        iptables -A INPUT -p tcp --dport 8992 -j DROP
        iptables -A INPUT -p tcp --dport 8993 -j DROP
      '';
    };
  };

  # Enhanced monitoring and logging
  services.journald.extraConfig = ''
    # Increase log retention for container security monitoring
    SystemMaxUse=500M
    SystemMaxFiles=10

    # Enhanced logging for container events
    ForwardToSyslog=yes
  '';

  # Create security monitoring script
  environment.systemPackages = [
    pkgs.curl
    pkgs.jq
    (pkgs.writeScriptBin "mcp-security-check" ''
      #!/usr/bin/env bash

      echo "=== MCP Container Security Status ==="

      # Check running containers
      echo "Running MCP containers:"
      ${pkgs.podman}/bin/podman ps --filter="name=mcp-" --format="table {{.Names}}\t{{.Status}}\t{{.Ports}}"

      # Check security contexts
      echo -e "\nContainer security contexts:"
      for container in $(${pkgs.podman}/bin/podman ps --filter="name=mcp-" --format="{{.Names}}"); do
        echo "=== $container ==="
        ${pkgs.podman}/bin/podman inspect "$container" | jq '.[] | {
          "Security": .HostConfig.SecurityOpt,
          "Capabilities": .HostConfig.CapDrop,
          "ReadOnlyRoot": .HostConfig.ReadonlyRootfs,
          "NetworkMode": .HostConfig.NetworkMode,
          "Memory": .HostConfig.Memory,
          "CpuQuota": .HostConfig.CpuQuota
        }'
        echo
      done

      # Check audit logs for container events
      echo "Recent container-related audit events:"
      journalctl --since="1 hour ago" -t audit | grep -i container | tail -5 || echo "No recent container audit events"

      # Check resource usage
      echo -e "\nContainer resource usage:"
      ${pkgs.podman}/bin/podman stats --no-stream --format="table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}" || echo "No running containers"
    '')
  ];
}
