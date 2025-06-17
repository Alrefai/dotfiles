# Codex Agent Requirements

This document provides the Codex CLI agent with authoritative project context,
ensuring that generated plans and changes align with the mission,
conventions, and constraints of this Nix configuration repository.

## 1. Project Goals
- Maintain and improve the Nix flake-based Home Manager and NixOS configuration
  for Mohammed’s machines.
- Enhance automation, readability, and maintainability of repository conventions.

## 2. Scope & Constraints
- Only modify files under version control (flake.nix, home.nix,
  configuration.nix, docs/, dotfiles/, bin/).
- The `.codex/` directory is git-ignored and reserved for agent workspace and
  dynamic planning files (plans, logs, etc.).
- Follow existing style guidelines and do not introduce external dependencies.
- Use flakes, support multi-system outputs, and preserve backward compatibility.

## 3. Coding & Commit Conventions
- Indentation: 2 spaces, no tabs, max 80 chars per line.
- Nix formatting: run `nix fmt` before committing.
- Shell scripts: `set -euo pipefail`, proper shebangs, lint with `shellcheck`.
- Commits: Conventional Commits with lower-case header ≤ 50 chars, body ≤ 72.

## 4. Deliverables & Milestones
- Add README.md with project overview and bootstrap instructions.
- Configure CI (flake checks, formatting) and update CI workflows.
- Modularize `home.nix` and `configuration.nix` into smaller modules.
- Create `.codex/` workspace and dynamic planning files.
- Add CHANGELOG.md and integrate dotfiles into Home Manager modules.

## 5. Additional Context
- See docs/CODE_REVIEW.md for a prioritized action plan and code review.
- Use docs/ai-tasks.md for the AI backlog of future tasks.