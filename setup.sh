#!/usr/bin/env bash

if ! command -v nix >/dev/null; then
  echo 'Installing nix via lix installer...'
  curl --proto '=https' --tlsv1.2 -sSf -L https://install.lix.systems/lix |
    sh -s -- install \
    --extra-conf 'auto-optimise-store = true' \
    --extra-conf 'use-xdg-base-directories = true' \
    --extra-conf 'trusted-users = root @adm @admin @wheel' || exit 1

  echo
  . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
  echo 'Starting nix daemon...'
else
  if [[ -e /etc/NIXOS ]]; then
    echo 'This system is running NixOS.'
    mkdir -p ~/.config/nix
    echo 'experimental-features = nix-command flakes' >> ~/.config/nix/nix.conf
    echo 'use-xdg-base-directories = true' >> ~/.config/nix/nix.conf
    echo 'Added extra configurations to ~/.config/nix/nix.conf'
    echo
    echo "Rebuild NixOS configurations from dotfiles repo..."
    sudo nixos-rebuild switch --flake github:alrefai/dotfiles#nixos --impure
  else
    echo 'This system is not running NixOS.'
  fi
fi

echo
echo "Switching home-manager configurations from dotfiles repo..."
nix run home-manager/master -- switch -b bak --flake github:alrefai/dotfiles

