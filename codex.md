# 🦜🔗 Codex Instructions for Mohammed’s Nix Configuration

> **Note:** Using model `codex-mini-latest`, provider `openai`, approval mode `suggest`
>
> **Recommended:** add `alias codex='op run --no-masking -- codex'` to your shell profile for automatic API‑key lookup.

## 📚 Project Overview

This repository contains Nix flakes for configuring:

- **Home Manager**: user-level dotfiles, packages, and environment.
- **NixOS system**: machine-level configuration.

We use a single `flake.nix` to generate Home Manager configurations for Mohammed’s machines
and a NixOS system configuration under `nixosConfigurations`.

## 🛠️ Setup & Development Shell

Prerequisites: Nix with flakes support, `nix-direnv`, and `direnv`.

```bash
# Enable nix-direnv integration
# Install nix-direnv and direnv if needed, then add to .envrc:
use flake .
direnv allow
```

To apply your Home Manager configuration:

```bash
home-manager switch --flake .#mohammed
```

To build and deploy the NixOS system:

```bash
sudo nixos-rebuild switch --flake .#nixos
```

## 🌲 Repository Structure

```
.
├── bin/
├── configuration.nix
├── docs/
│   ├── CODE_REVIEW.md
│   └── ai-tasks.md
├── dotfiles/
├── sessions/
├── flake.nix
├── flake.lock
├── home.nix
├── setup.sh
├── treefmt.nix
└── .editorconfig
```

## 🎯 Style & Conventions

- **Indentation:** 2 spaces, no tabs, max 80 chars per line.
- **Nix Formatting:** run `nix fmt`.
- **Shell scripts:** `set -euo pipefail`, proper shebangs, linted by `shellcheck`.
- **Commits:** Conventional Commits (header ≤ 50 chars, body ≤ 72 chars).
- **Code blocks:** annotate with language comments for syntax highlighting.

## 🔨 Common Tasks

| Task                            | Command                                  |
|---------------------------------|------------------------------------------|
| Format Nix code                 | `nix fmt`                                |
| Run flake checks                | `nix flake check`                        |
| Apply Home Manager config       | `home-manager switch --flake .#mohammed` |
| Build NixOS system              | `sudo nixos-rebuild switch --flake .#nixos` |

## 📋 Outstanding AI‑Backlog

Use Codex to work on these tasks. Example:

```bash
codex --project-doc docs/ai-tasks.md "Implement README.md and bootstrap docs"
```

- [ ] Add README.md with project purpose, prerequisites, and instructions.
- [ ] Add CI workflows for flake checks and formatting.
- [ ] Improve `setup.sh` for automated bootstrap.
- [ ] Modularize `home.nix` and `configuration.nix` into smaller modules.
- [ ] Automate flake updates with a helper script.
- [ ] Integrate dotfiles into Home Manager modules.
- [ ] Lint and document scripts in `bin/`.
- [ ] Audit repository for any sensitive data.
- [ ] Review and refine `treefmt.nix` excludes.

## 🗒️ AI Session Workflow

At the end of each AI session, summarize completed tasks and outstanding todos:

```bash
codex -q "Summarize this session's completed tasks and outstanding todos" \
  > docs/ai-tasks.md
```

At the start of a new session, recap last session:

```bash
codex -q "Summarize the last session's completed tasks and next steps"
```

## 🔄 Resume last AI session

```bash
codex --view sessions/last.json
```

## 🤖 How to invoke Codex

```bash
# Interactive (auto-loads codex.md):
codex "Refactor Nix flakes configuration"

# Full-context batch refactor:
codex --full-context "Update style conventions in codex.md"
```

*This file is maintained by the Codex CLI agent. Do not edit manually unless updating agent configuration.*
