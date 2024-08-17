#!/usr/bin/env bash

# install nix via determinate nix installer
#
# trusted-users = $(whoami) allows to accept a flake's `nixConfig`
sh -s -- install --extra-conf "trusted-users = $(whoami)" < <(
  curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix
)

# run nix daemon
. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh

# install git if necessary
command -v git >/dev/null || nix profile install nixpkgs#git

# setup global devbox
nix profile install nixpkgs#devbox
devbox global pull https://github.com/Alrefai/dotfiles.git
eval "$(devbox global shellenv --recompute)"
eval "$(devbox global shellenv --preserve-path-stack -r)" && hash -r

# activate home-manager home profile
devbox global run switch-home
