# Codex Configuration and Project Action Plan

This file contains configuration and guidelines for the Codex CLI agent
to operate efficiently in this repository, as well as a high-level
action plan for improving the repository structure and development
workflow.

## 1. Repository Overview

Top-level files and directories:

```
. ├── bin
. ├── configuration.nix
. ├── dotfiles
. ├── .editorconfig
. ├── flake.lock
. ├── flake.nix
. ├── home.nix
. ├── setup.sh
. └── treefmt.nix
```

## 2. Action Plan

### Short-term
- Add a README.md with project purpose, prerequisites, and bootstrap instructions.
- Enable CI workflows to run `nix flake check` and format/lint checks on each PR.
- Document and improve `setup.sh` for automatic bootstrap.

### Mid-term
- Modularize large Nix files (`home.nix`, `configuration.nix`) into smaller modules.
- Automate flake input updates via a helper script.
- Integrate dotfiles (`ssh`, `wezterm`) into Home Manager modules.

### Long-term
- Lint and document custom scripts in `bin/`.
- Audit repository for any sensitive secrets.
- Refine formatting/linting excludes in `treefmt.nix` and ensure `.editorconfig` is respected.

## 3. Agent Guidelines

- Follow the repository coding guidelines: Conventional Commits, Nix formatting.
- Use `nix flake check` to validate changes and `nix flake check --checks formatting` for format enforcement.
- Commit changes to feature branches, and open PRs for review.

---

*This file is maintained by the Codex CLI agent. Do not edit manually unless updating agent configuration.*