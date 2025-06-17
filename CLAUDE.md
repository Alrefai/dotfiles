# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with
code in this repository.

## Codebase Overview

This is a multi-platform Nix configuration repository using Home Manager for
user environment management, supporting Linux, macOS, and both aarch64/x86_64
architectures.

**Key Files:**

- `flake.nix` - Main flake with inputs, outputs, and platform configurations
- `home.nix` - Core Home Manager configuration with packages, programs, and
  shell setup
- `configuration.nix` - NixOS system configuration
- `modules/darwin/default.nix` - macOS system settings
- `treefmt.nix` - Code formatting configuration

## Development Commands

**Code Formatting:**

```bash
nix fmt              # Format entire project using treefmt
fmt                  # Alias for treefmt -vv
```

**Configuration Management:**

```bash
# Apply Home Manager configuration
home-manager switch --flake .

# NixOS system rebuild (if on NixOS)
sudo nixos-rebuild switch --flake .#nixos

# Darwin system rebuild (if on macOS)
darwin-rebuild switch --flake .#mimacvm
```

**Validation:**

```bash
nix flake check      # Validate flake outputs and run checks
nix flake show       # Display available flake outputs
```

## Architecture Notes

**Multi-Platform Support:** Configuration uses conditional logic
(`pkgs.stdenv.isDarwin`) to handle platform differences. The flake supports
multiple systems through `flake-utils.lib.eachDefaultSystem`.

**External Dependencies:** Managed through flake inputs including nixpkgs,
home-manager, nix-darwin, and custom configurations (minvim, mitmux).

**Formatting Tools:** Configured via treefmt with alejandra (Nix), dprint
(Markdown), statix (Nix linter), shellcheck, and shfmt.

**Shell Environment:** Extensive customization in `home.nix` with custom
aliases, environment variables following XDG spec, and integration with tools
like atuin, zoxide, and starship.

**Theming:** Catppuccin theme applied consistently across all applications and
tools.
