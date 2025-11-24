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
    settings = {
      # Disable auto-optimise-store because of this issue:
      # https://github.com/NixOS/nix/issues/7273
      # "error: cannot link '/nix/store/.tmp-link-xxxxx-xxxxx'
      # to '/nix/store/.links/xxxx': File exists"
      auto-optimise-store = false;
      experimental-features = ["nix-command" "flakes"];
      substituters = [
        "https://nix-community.cachix.org"
      ];
      extra-trusted-substituters = ["https://cache.flakehub.com"];
      extra-trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "cache.flakehub.com-3:hJuILl5sVK4iKm86JzgdXW12Y2Hwd5G07qKtHTOcDCM="
        "cache.flakehub.com-4:Asi8qIv291s0aYLyH6IOnr5Kf6+OF14WVjkE6t3xMio="
        "cache.flakehub.com-5:zB96CRlL7tiPtzA9/WKyPkp3A2vqxqgdgyTVNGShPDU="
        "cache.flakehub.com-6:W4EGFwAGgBj3he7c5fNh9NkOXw0PUVaxygCVKeuvaqU="
        "cache.flakehub.com-7:mvxJ2DZVHn/kRxlIaxYNMuDG1OvMckZu32um1TadOR8="
        "cache.flakehub.com-8:moO+OVS0mnTjBTcOUh2kYLQEd59ExzyoW1QgQ8XAARQ="
        "cache.flakehub.com-9:wChaSeTI6TeCuV/Sg2513ZIM9i0qJaYsF+lZCXg0J6o="
        "cache.flakehub.com-10:2GqeNlIp6AKp4EF2MVbE1kBOp9iBSyo0UPR9KoR0o1Y="
      ];
      builders-use-substitutes = true;
      trusted-users = ["@admin"];
      use-xdg-base-directories = true;
    };
  };

  # Set the host platform
  nixpkgs.hostPlatform = system;

  environment = {
    # Override the default nix profiles and their order in path.
    # Enforce the use of home manager nix profile in `XDG_STATE_HOME` when
    # using `use-xdg-base-directories`.
    #
    # This fixes:
    # - stand-alone home-manager installation.
    # - eliminate `~/.nix-profile`
    # - multiple versions of nix found in PATH
    #
    # NOTE: `use-xdg-base-directories` must be set to `true`
    # in `/etc/nix/nix.conf`
    profiles = lib.mkForce [
      "$HOME/.local/state/nix/profile" # home manager nix profile
      "/run/current-system/sw" # darwin nix profile
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
