#!/usr/bin/env bash

# install nix via determinate nix installer
#
# trusted-users = $(whoami) allows to accept a flake's `nixConfig`
sh -s -- install --extra-conf "trusted-users = $(whoami)" < <(
  curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix
)

# run nix daemon
. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh

# setup devbox
nix profile install nixpkgs#devbox
eval "$(devbox global shellenv --recompute)"
eval "$(devbox global shellenv --preserve-path-stack -r)" && hash -r

