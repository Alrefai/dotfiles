# MCP (Model Context Protocol) Servers Configuration
# Secure-by-default container runtime for nixos host only
{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit
    (lib)
    mkEnableOption
    mkOption
    mkIf
    types
    optional
    fold
    attrNames
    concatStringsSep
    ;
  cfg = config.services.mcp-servers;

  # MCP management script
  mcpScript = pkgs.writeShellScriptBin "mcp" ''
    set -euo pipefail

    # Colors for output
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    NC='\033[0m' # No Color

    log() {
      echo -e "''${BLUE}[MCP]''${NC} $1"
    }

    error() {
      echo -e "''${RED}[ERROR]''${NC} $1" >&2
    }

    success() {
      echo -e "''${GREEN}[SUCCESS]''${NC} $1"
    }

    warn() {
      echo -e "''${YELLOW}[WARNING]''${NC} $1"
    }

    case "''${1:-}" in
      start)
        log "Starting MCP servers..."
        systemctl start mcp-playwright mcp-sequential mcp-semgrep
        sleep 2
        if systemctl is-active --quiet mcp-playwright mcp-sequential mcp-semgrep; then
          success "All MCP servers started successfully"
        else
          error "Some MCP servers failed to start"
          $0 status
        fi
        ;;

      stop)
        log "Stopping MCP servers..."
        systemctl stop mcp-playwright mcp-sequential mcp-semgrep
        success "MCP servers stopped"
        ;;

      restart)
        log "Restarting MCP servers..."
        systemctl restart mcp-playwright mcp-sequential mcp-semgrep
        success "MCP servers restarted"
        ;;

      status)
        log "MCP Servers Status:"
        echo
        for service in mcp-playwright mcp-sequential mcp-semgrep; do
          if systemctl is-active --quiet "$service"; then
            echo -e "  ''${GREEN}●''${NC} $service: active"
          else
            echo -e "  ''${RED}●''${NC} $service: inactive"
          fi
        done
        echo

        # Show container status if any are running
        if ${pkgs.podman}/bin/podman ps --filter="name=mcp-" --quiet | grep -q .; then
          log "Container Status:"
          ${pkgs.podman}/bin/podman ps --filter="name=mcp-" --format="table {{.Names}}\t{{.Status}}\t{{.Ports}}"
        fi
        ;;

      logs)
        if [ -n "''${2:-}" ]; then
          case "$2" in
            playwright|sequential|semgrep)
              log "Following logs for mcp-$2..."
              journalctl -u mcp-$2 -f
              ;;
            *)
              error "Invalid server name. Use: playwright, sequential, or semgrep"
              exit 1
              ;;
          esac
        else
          log "Recent logs from all MCP servers:"
          journalctl -u mcp-playwright -u mcp-sequential -u mcp-semgrep -n 20 --no-pager
        fi
        ;;

      endpoints)
        log "MCP Server Endpoints for Claude Code:"
        echo
        echo "  Playwright (Web Testing):     http://10.88.0.1:8991"
        echo "  Sequential (AI Thinking):     http://10.88.0.1:8992"
        echo "  Semgrep (Security Scanner):   http://10.88.0.1:8993"
        echo
        log "Transport Protocol: Server-Sent Events (SSE)"
        ;;

      rebuild)
        log "Rebuilding MCP container images..."
        systemctl restart load-mcp-images
        if systemctl is-active --quiet load-mcp-images; then
          success "MCP images rebuilt successfully"
          warn "Restart services to use new images: mcp restart"
        else
          error "Failed to rebuild MCP images"
          journalctl -u load-mcp-images -n 10 --no-pager
        fi
        ;;

      security)
        log "Running security check..."
        mcp-security-check
        ;;

      health)
        log "Checking MCP server health..."
        errors=0

        # Check if containers are running
        for server in playwright sequential semgrep; do
          port=$((8990 + $(echo "playwright sequential semgrep" | tr ' ' '\n' | nl -v0 | grep "$server" | cut -f1) + 1))

          if [ "$server" = "playwright" ]; then
            # Playwright has network access, can test HTTP
            if timeout 5 curl -sf "http://10.88.0.1:$port/health" >/dev/null 2>&1; then
              success "$server: healthy"
            else
              warn "$server: health check failed (port $port)"
              ((errors++))
            fi
          else
            # Network-isolated servers, check container status only
            if ${pkgs.podman}/bin/podman ps --filter="name=mcp-$server" --quiet | grep -q .; then
              success "$server: container running"
            else
              error "$server: container not running"
              ((errors++))
            fi
          fi
        done

        if [ $errors -eq 0 ]; then
          success "All MCP servers are healthy"
        else
          error "$errors servers have issues"
          exit 1
        fi
        ;;

      *)
        log "MCP Server Management Tool"
        echo
        echo "Usage: mcp <command> [server]"
        echo
        echo "Commands:"
        echo "  start      - Start all MCP servers"
        echo "  stop       - Stop all MCP servers"
        echo "  restart    - Restart all MCP servers"
        echo "  status     - Show status of all servers"
        echo "  logs       - Show logs (optionally for specific server)"
        echo "  endpoints  - Show server endpoints for Claude Code"
        echo "  rebuild    - Rebuild container images"
        echo "  security   - Run security audit"
        echo "  health     - Check server health"
        echo
        echo "Servers: playwright, sequential, semgrep"
        echo
        echo "Examples:"
        echo "  mcp start           # Start all servers"
        echo "  mcp logs playwright # Follow Playwright logs"
        echo "  mcp security        # Run security audit"
        ;;
    esac
  '';

  # MCP debug script
  mcpDebugScript = pkgs.writeShellScriptBin "mcp-debug" ''
    echo "=== MCP Debug Information ==="

    echo "Container images:"
    ${pkgs.podman}/bin/podman images | grep mcp
    echo

    echo "Running containers:"
    ${pkgs.podman}/bin/podman ps --filter="name=mcp-"
    echo

    echo "Container logs (last 10 lines each):"
    for container in $(${pkgs.podman}/bin/podman ps --filter="name=mcp-" --format="{{.Names}}"); do
      echo "=== $container ==="
      ${pkgs.podman}/bin/podman logs --tail=10 "$container" 2>&1 || echo "No logs available"
      echo
    done

    echo "Service status:"
    systemctl status mcp-playwright mcp-sequential mcp-semgrep --no-pager | grep -E "(●|Active:)"

    echo "Network configuration:"
    ss -tlnp | grep -E ":(8991|8992|8993)" || echo "No MCP ports bound"

    echo "Resource usage:"
    ${pkgs.podman}/bin/podman stats --no-stream 2>/dev/null || echo "No running containers"
  '';

  # Security configurations
  mcpSecurity = {
    # Common security settings for all MCP services
    commonServiceConfig = {
      # Process restrictions
      NoNewPrivileges = true;
      PrivateTmp = true;
      PrivateDevices = true;
      ProtectHome = true;
      ProtectSystem = "strict";
      ProtectKernelTunables = true;
      ProtectKernelModules = true;
      ProtectControlGroups = true;

      # Namespace restrictions
      RestrictNamespaces = "mnt pid user";
      RestrictRealtime = true;
      RestrictSUIDSGID = true;

      # Capability restrictions (beyond container level)
      AmbientCapabilities = "";
      CapabilityBoundingSet = "";

      # System call filtering
      SystemCallFilter = [
        "~@clock"
        "~@debug"
        "~@module"
        "~@mount"
        "~@raw-io"
        "~@reboot"
        "~@swap"
        "~@privileged"
        "@system-service"
      ];

      # Resource limits
      MemoryDenyWriteExecute = true;
      LockPersonality = true;

      # Logging and monitoring
      StandardOutput = "journal";
      StandardError = "journal";
      SyslogIdentifier = "mcp-container";
    };

    # Server-specific security profiles
    serverProfiles = {
      playwright = {
        # Playwright needs some additional capabilities for browser sandboxing
        extraContainerArgs = [
          "--security-opt=no-new-privileges:true"
          "--security-opt=seccomp:unconfined" # Needed for browser sandboxing
          "--cap-drop=ALL"
          "--cap-add=SYS_ADMIN" # Required for browser sandboxing
          "--cap-add=DAC_OVERRIDE"
          # Network restrictions
          "--dns=8.8.8.8"
          "--dns=8.8.4.4"
          # Resource limits
          "--memory=512m"
          "--memory-swap=512m"
          "--cpus=1.0"
          "--pids-limit=200"
          # Filesystem restrictions
          "--read-only"
          "--tmpfs=/tmp:rw,noexec,nosuid,size=100m"
          "--tmpfs=/var/tmp:rw,noexec,nosuid,size=50m"
        ];
        description = "MCP Playwright Server (Network Access for Web Testing)";
      };

      sequential = {
        extraContainerArgs = [
          "--security-opt=no-new-privileges:true"
          "--security-opt=seccomp:default"
          "--cap-drop=ALL"
          "--cap-add=DAC_OVERRIDE"
          # Complete network isolation
          "--network=none"
          # Minimal resource limits
          "--memory=256m"
          "--memory-swap=256m"
          "--cpus=0.5"
          "--pids-limit=50"
          # Filesystem restrictions
          "--read-only"
          "--tmpfs=/tmp:rw,noexec,nosuid,size=50m"
        ];
        description = "MCP Sequential Thinking Server (Air-Gapped)";
      };

      semgrep = {
        extraContainerArgs = [
          "--security-opt=no-new-privileges:true"
          "--security-opt=seccomp:default"
          "--cap-drop=ALL"
          "--cap-add=DAC_OVERRIDE"
          # Complete network isolation for security scanning
          "--network=none"
          # Resource limits for static analysis
          "--memory=512m"
          "--memory-swap=512m"
          "--cpus=1.0"
          "--pids-limit=100"
          # Filesystem restrictions
          "--read-only"
          "--tmpfs=/tmp:rw,noexec,nosuid,size=100m"
        ];
        description = "MCP Semgrep Security Scanner (Air-Gapped)";
      };
    };
  };

  # Server configurations with enhanced security
  servers = {
    playwright = {
      port = 8991;
      network = "bridge"; # Needs network access for web testing
      memory = "512m";
      cpus = "1.0";
      pidsLimit = 200;
      description = "MCP Playwright Server - Web Testing with Network Access";
    };

    sequential = {
      port = 8992;
      network = "none"; # Air-gapped for thinking tasks
      memory = "256m";
      cpus = "0.5";
      pidsLimit = 50;
      description = "MCP Sequential Thinking Server - Air-Gapped";
    };

    semgrep = {
      port = 8993;
      network = "none"; # Air-gapped for security scanning
      memory = "512m";
      cpus = "1.0";
      pidsLimit = 100;
      description = "MCP Semgrep Security Scanner - Air-Gapped";
    };
  };

  # Function to create systemd service for each MCP server
  mkMcpService = name: server: {
    "mcp-${name}" = {
      inherit (server) description;
      after = ["podman.service" "load-mcp-images.service"];
      requires = ["load-mcp-images.service"];
      wantedBy = optional cfg.enable "multi-user.target";

      serviceConfig =
        # Apply common security settings
        mcpSecurity.commonServiceConfig
        // {
          Type = "simple";
          Restart = "on-failure";
          RestartSec = "10s";

          # Container lifecycle management
          ExecStartPre = [
            "${pkgs.podman}/bin/podman rm -f mcp-${name} || true"
            # Verify image exists
            "${pkgs.podman}/bin/podman image exists mcp-${name}:local"
          ];

          ExecStart = let
            # Get server-specific security profile
            securityProfile = mcpSecurity.serverProfiles.${name};

            # Base container arguments
            baseArgs = [
              "${pkgs.podman}/bin/podman"
              "run"
              "--rm"
              "--name=mcp-${name}"
              "--network=${server.network}"
              "--user=9001:9001"
              "--memory=${server.memory}"
              "--memory-swap=${server.memory}"
              "--cpus=${server.cpus}"
              "--pids-limit=${toString server.pidsLimit}"
            ];

            # Network binding (only if not isolated)
            networkArgs =
              if server.network != "none"
              then [
                "-p"
                "10.88.0.1:${toString server.port}:3000"
              ]
              else [];

            # Security arguments from profile
            securityArgs = securityProfile.extraContainerArgs;

            # Final image specification
            imageArgs = ["mcp-${name}:local"];

            # Combine all arguments
            allArgs = baseArgs ++ networkArgs ++ securityArgs ++ imageArgs;
          in
            concatStringsSep " " allArgs;

          ExecStop = "${pkgs.podman}/bin/podman stop mcp-${name}";

          # Health monitoring
          ExecReload = "${pkgs.podman}/bin/podman restart mcp-${name}";

          # Enhanced service-level security
          User = "root"; # Needed for podman operations
          Group = "root";

          # Timeout settings
          TimeoutStartSec = "60s";
          TimeoutStopSec = "30s";
        };

      # Service environment
      environment = {
        PODMAN_USERNS = "keep-id";
        PODMAN_SYSTEMD_UNIT = "%n";
      };
    };
  };
in {
  # Import required modules
  imports = [
    ./images.nix
    ./security.nix
  ];

  # Configuration options
  options.services.mcp-servers = {
    enable =
      mkEnableOption "MCP servers with locally-built secure container images";

    debug = mkOption {
      type = types.bool;
      default = false;
      description = "Enable debug logging for MCP services";
    };

    enableFirewall = mkOption {
      type = types.bool;
      default = false;
      description = "Enable firewall rules for MCP ports (can complicate testing)";
    };
  };

  # Implementation
  config = mkIf cfg.enable {
    # Create systemd services for each server
    systemd.services = fold (
      name: acc: acc // mkMcpService name servers.${name}
    ) {} (attrNames servers);

    # Management and monitoring tools
    environment.systemPackages = [
      pkgs.curl
      mcpScript
      mcpDebugScript
    ];

    # Create log directory for MCP services
    systemd.tmpfiles.rules = [
      "d /var/log/mcp 0750 root root -"
    ];
  };
}
