# Modular NixOS Configuration Restructure Plan

## Current Issues

- Single `nixosConfigurations.nixos` hardcoded to current VM
- Imports host-specific `/etc/nixos/configuration.nix` (OrbStack VM)
- No modularity for multiple machines like the elegant Darwin setup

## Solution: Apply Darwin Pattern to NixOS

### 1. Create New Git Branch

```bash
git checkout -b refactor/modular-nixos-config
```

### 2. Directory Structure (Mirroring Darwin pattern)

```
modules/
├── darwin/              # Existing (keep as-is)
├── nixos/               # New modular NixOS system
│   ├── common/          # Shared NixOS configuration
│   │   ├── default.nix  # Base NixOS config
│   │   ├── nix.nix      # Nix daemon settings
│   │   ├── users.nix    # User configuration  
│   │   └── packages.nix # System packages
│   └── hosts/           # Machine-specific overrides
│       ├── nixos-vm/    # Current aarch64 VM
│       │   ├── default.nix
│       │   └── hardware.nix
│       └── mimacbook/   # Old x86_64 MacBook
│           ├── default.nix
│           └── hardware.nix
```

### 3. Update flake.nix Structure

Transform single `nixosConfigurations.nixos` into modular `nixosConfigurations`
object:

- Add `mkNixOSHost` helper function (like `mkDarwinHost`)
- Create `hosts` object for easy machine addition
- Support per-host `extraModules` and `system` specification

### 4. Extract and Modularize Current Configuration

- Move common config from `configuration.nix` to `modules/nixos/common/`
- Create VM-specific config in `modules/nixos/hosts/nixos-vm/`
- Remove hardcoded `/etc/nixos/configuration.nix` import

### 5. Create mimacbook Configuration

- New `modules/nixos/hosts/mimacbook/default.nix`
- x86_64-linux system specification
- Include distributed builds configuration
- Machine-specific hardware configuration

### 6. Benefits Achieved

- **Cross-compilation support**: Build mimacbook config on fast machine
- **Clean separation**: Common vs machine-specific configuration
- **Easy scaling**: Add new machines by just adding to hosts object
- **Consistent pattern**: Same modular approach as Darwin configs
- **Maintainable**: Changes to common config affect all machines

### 7. Test Plan

- Verify current VM still builds with new structure
- Cross-compile mimacbook configuration on fast machine
- Push pre-built system to cachix for instant old MacBook rebuilds

This creates the foundation for the cross-compilation build strategy we
discussed!

## Cross-Compilation Workflow (Post-Refactor)

### Build Complete System for Old MacBook

```bash
# On fast machine (aarch64) - build for old machine (x86_64)
nix build --system x86_64-linux .#nixosConfigurations.mimacbook.config.system.build.toplevel

# Push everything to cachix
cachix push midot ./result
```

### Old MacBook Rebuild (Instant)

```bash
# On old MacBook - downloads pre-built system
sudo nixos-rebuild switch --flake .#mimacbook
```

## Context from Previous Session

- Fast machine: aarch64-linux (100.69.200.16, nixos) - 8 cores
- Old machine: x86_64-linux (100.112.54.117, mimacbook) - 2 cores, overheated
- Tailscale SSH working between machines
- User mohammed in @wheel group on both machines
- Cachix (midot.cachix.org) configured and working
- Distributed builds configured but old machine overheated before testing
- Cross-compilation is preferred solution: 5+ hours → 2 minutes
