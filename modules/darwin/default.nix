{
  lib,
  pkgs,
  hostname,
  username,
  system,
  ...
}: {
  # Configure Nix
  nix = {
    channel.enable = false;
    gc = {
      automatic = true;
      options = "--delete-older-than 7d";
    };
    optimise.automatic = true;
    package = pkgs.lixPackageSets.stable.lix;
    settings =
      (import ../shared/nix.nix).commonSettings
      // {
        # Disable auto-optimise-store because of this issue:
        # https://github.com/NixOS/nix/issues/7273
        # "error: cannot link '/nix/store/.tmp-link-xxxxx-xxxxx'
        # to '/nix/store/.links/xxxx': File exists"
        auto-optimise-store = false;
        # Darwin specific caches
        substituters = [
          "https://nix-community.cachix.org"
        ];
        extra-trusted-substituters = ["https://cache.flakehub.com"];
        extra-trusted-public-keys =
          (import ../../shared/nix.nix).commonSettings.extra-trusted-public-keys
          ++ [
            "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
          ];
        builders-use-substitutes = true;
        trusted-users = ["@admin"];
      };
  };

  # Set the host platform
  nixpkgs.hostPlatform = system;

  environment = {
    # Override the default nix profiles and their order in path.
    # Enforce the use of nix profiles in `XDG_STATE_HOME` when using
    # `use-xdg-base-directories`.
    # This fixes stand-alone home-manager installation.
    # Also, this will eliminate `~/.nix-profile`
    #
    # NOTE: `use-xdg-base-directories` must be set to `true`
    # in `/etc/nix/nix.conf`
    profiles = lib.mkForce [
      "$HOME/.local/state/nix/profile"
      "/run/current-system/sw"
      "/nix/var/nix/profiles/default"
    ];
    systemPackages = [pkgs.git];
  };

  users.users.${username}.shell = pkgs.zsh;

  programs = {
    zsh.enable = true;
  };

  # Configure Homebrew
  homebrew = {
    enable = true;
    casks = [
      "1password"
      "ghostty"
      "zen"
    ];
    global.autoUpdate = false;
    onActivation = {
      upgrade = true;
      cleanup = "zap";
    };
  };

  # Set the hostname
  networking = {
    hostName = hostname;
    computerName = hostname;
  };

  # Enable Tailscale
  services.tailscale.enable = true;

  system = {
    # activateSettings -u will reload the settings from the database and apply
    # them to the current session, so we do not need to logout and login again
    # to make the changes take effect.
    #
    # ---
    # references:
    # - https://github.com/ryan4yin/nix-darwin-kickstarter/blob/b73c5d62a2fcdb7546618c7e83dbc7d8853fca99/minimal/modules/system.nix
    activationScripts.postActivation.text = ''
      /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
    '';
    defaults = {
      dock.autohide = true;
      finder = {
        AppleShowAllExtensions = true;
        FXRemoveOldTrashItems = true;
        ShowExternalHardDrivesOnDesktop = false;
        ShowPathbar = true;
        ShowStatusBar = true;
        _FXSortFoldersFirst = true;
      };
      loginwindow.GuestEnabled = false;
      trackpad = {
        FirstClickThreshold = 0;
        SecondClickThreshold = 0;
      };
      NSGlobalDomain = {
        _HIHideMenuBar = false;
        AppleInterfaceStyle = "Dark";
        "com.apple.trackpad.forceClick" = true;
      };
      smb.NetBIOSName = hostname;
      SoftwareUpdate.AutomaticallyInstallMacOSUpdates = true;
      WindowManager.StandardHideDesktopIcons = true;
    };
    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToControl = true;
    };
    primaryUser = username;
    stateVersion = 6;
  };
}
