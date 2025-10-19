# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with
code in this repository.

## Repository Overview

This is a multi-platform Nix configuration repository supporting home-manager
(standalone), nix-darwin, and NixOS. The repository is structured as a flake
that can be forked and customized by replacing "mohammed" with the target
username throughout the configuration.

## Essential Commands

### Flake Management

- `nix flake check --impure` - Validate all configurations (requires --impure
  for OrbStack /etc/nixos imports)
- `nix fmt` - Format all Nix files using alejandra and dprint for markdown
- `nix build .#apps.aarch64-linux.mcp-playwright` - Build individual MCP
  container apps

### System Deployment

- `sudo nixos-rebuild switch --flake .#nixos --impure` - Deploy NixOS
  configuration (nixos host)
- `home-manager switch --flake .` - Deploy home-manager configuration

### MCP Server Management

The repository includes a comprehensive MCP (Model Context Protocol) server
infrastructure with dedicated management commands:

- `mcp start` - Start all MCP servers (playwright, semgrep)
- `mcp stop` - Stop all MCP servers
- `mcp status` - Show systemd service and container status
- `mcp logs [server]` - View logs for all servers or specific server
- `mcp health` - Run health checks on all servers
- `mcp endpoints` - Display server endpoints for Claude Code integration
- `mcp-debug` - Comprehensive debugging information dump

### Container Operations

- `nix run .#mcp-playwright` - Load Playwright container into Podman
- `nix run .#mcp-semgrep` - Load Semgrep container into Podman
- `podman images | grep mcp` - List MCP container images

## Architecture

### Multi-Platform Structure

The flake outputs support three platforms through a unified configuration
approach:

- **NixOS**: Full system configurations with modular host-specific modules
- **Darwin (macOS)**: System configurations using nix-darwin
- **Home Manager**: User environment management for any Linux/macOS system

### Host-Specific Modules

NixOS configurations use a modular approach:

- `modules/nixos/common/` - Shared base configuration across all NixOS hosts
- `modules/nixos/hosts/nixos/` - OrbStack VM-specific configuration with MCP
  integration
- `modules/nixos/hosts/mimacbook/` - Alternative host configuration

### MCP Container Infrastructure

The MCP implementation demonstrates advanced container orchestration in Nix:

**Container Architecture:**

- `modules/nixos/hosts/nixos/mcp/images.nix` - Container image definitions using
  nix2container
- `modules/nixos/hosts/nixos/mcp/services.nix` - NixOS systemd services for
  container lifecycle
- `modules/nixos/hosts/nixos/mcp/security.nix` - Security policies and hardening
- `modules/nixos/hosts/nixos/mcp/default.nix` - Main module with management
  scripts

**Security Model:**

- **Playwright**: Network-enabled for web testing with browser sandboxing
  capabilities
- **Semgrep**: Air-gapped (network=none) for secure code analysis
- All containers run with minimal privileges, read-only filesystems, and
  resource limits

**Python Package Building:** The Semgrep container demonstrates modern Nix
Python packaging:

- Reads `pyproject.toml` programmatically using `builtins.fromTOML`
- Uses `pyproject = true` with automatic build system detection
- Handles missing nixpkgs dependencies gracefully with fallbacks
- Includes proper runtime dependency wrapping

### Development Tooling

- **treefmt-nix**: Automated formatting with alejandra (Nix), dprint (Markdown),
  shellcheck/shfmt (Shell)
- **Lix**: Alternative Nix implementation for improved developer experience
- **Catppuccin**: Consistent theming across all applications

## Key Patterns

### Flake Input Management

External dependencies are categorized:

- MCP servers use `flake = false` for source-only inputs
- All nixpkgs inputs follow the main nixpkgs for consistency
- Development tools (treefmt, home-manager) are version-locked

### Container Build Strategy

MCP containers use layered builds for efficiency:

- Base security-hardened layer shared across containers
- Language-specific layers (Node.js, Python) for runtime dependencies
- Application layers with proper dependency resolution

### Security-First Design

All MCP services implement defense-in-depth:

- Container-level security (capabilities, namespaces, seccomp)
- Systemd service hardening (filesystem protection, system call filtering)
- Network isolation by default with explicit exceptions

### Username Parameterization

The entire configuration is parameterized for easy forking:

- Username defined once in flake.nix (`username = "mohammed"`)
- All host configurations inherit and use this parameter
- Home directory paths automatically resolve from username

## Configuration Notes

### OrbStack Integration

The nixos host configuration imports `/etc/nixos/configuration.nix` to maintain
compatibility with OrbStack's managed configuration. This requires `--impure`
flag for flake operations.

### Python Dependency Handling

When working with Python packages not in nixpkgs:

- Parse `pyproject.toml` using `builtins.fromTOML` for metadata
- Use `dontCheckRuntimeDeps = true` to bypass missing dependency checks
- Provide compatible substitutes from nixpkgs where possible
- Wrap binaries with `--prefix PATH` for external tool dependencies

### Container Port Mapping

MCP servers use specific port allocations:

- Playwright: 8991 (network-enabled)
- Sequential: 8992 (disabled - build issues)
- Semgrep: 8993 (air-gapped, internal port 8000)
- All bound to 10.88.0.1 for OrbStack compatibility
