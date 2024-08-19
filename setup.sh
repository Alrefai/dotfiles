#!/usr/bin/env bash

# install nix via determinate nix installer
if ! command -v nix >/dev/null; then
  sh -s -- install --extra-conf "trusted-users = $(whoami)" < <(
    curl --proto '=https' --tlsv1.2 -sSf -L \
      https://install.determinate.systems/nix
  ) || exit 1

  # run nix daemon
  . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
else
  mkdir -p ~/.config/nix
  echo 'experimental-features = nix-command flakes' >> ~/.config/nix/nix.conf
fi

# start a shell with git and neovim in the environment
nix shell nixpkgs/nixos-24.05#{git,neovim}

