{
  config,
  lib,
  pkgs,
  hostname,
  username,
  system,
  ...
} @ args: let
  roles = {
    default = {
      withCommunication = false;
      withDevTools = false;
      withGaming = false;
      withMediaServer = false;
      withVirtualization = false;
    };
    mediaServer = {
      withCommunication = true;
      withDevTools = false;
      withGaming = true;
      withMediaServer = true;
      withVirtualization = true;
    };
    main = {
      withCommunication = true;
      withDevTools = true;
      withGaming = true;
      withMediaServer = false;
      withVirtualization = true;
    };
  };

  machineRole = args.machineRole or "default";

  inherit
    (roles.${machineRole})
    withCommunication
    withDevTools
    withGaming
    withMediaServer
    withVirtualization
    ;
in {
  imports = [../common];

  # Set the host platform
  nixpkgs = {
    hostPlatform = system;
    config.allowDeprecatedx86_64Darwin = true;
  };

  /**
  Override the default Nix profiles and their order in PATH.

  When `use-xdg-base-directories` is enabled, use the Home Manager profile under
  `XDG_STATE_HOME` and remove obsolete profile entries from `NIX_PROFILES`.

  This also fixes in Darwin:
  - Stand-alone Home Manager installation.
  - `~/.nix-profile` being used.
  - Multiple versions of Nix being found in PATH.

  NOTE: `use-xdg-base-directories` must be set to `true` in `/etc/nix/nix.conf`.

  */
  environment = {
    profiles = lib.mkIf config.nix.settings.use-xdg-base-directories (
      lib.mkForce [
        "$HOME/.local/state/nix/profile" # home manager nix profile
        "/run/current-system/sw" # nixos and darwin nix profile
      ]
    );
    systemPackages = map lib.lowPrio (builtins.attrValues {
      inherit
        (pkgs)
        curl
        gitMinimal
        ;
      inherit (pkgs.ghostty) terminfo;
      inherit (pkgs.wrappers) bottom neovim;
    });
  };

  users.users.${username}.shell = pkgs.zsh;

  programs = {
    zsh.enable = true;
  };

  # Configure Homebrew
  homebrew = {
    enable = true;
    casks =
      [
        # Terminals
        "ghostty"
        "wezterm"

        # Privacy and security
        "1password"
        "adguard"
        "backblaze"

        # Browsers
        "arc"
        "zen"

        # Utilities
        # "grandperspective"
        # "kap"
        "opencore-patcher"
        "raycast"
        "resilio-sync"
        "the-unarchiver"

        # Productivity
        "obsidian"
        "taskpaper"

        # Entertainment
        "plex"
      ]
      ++ lib.optionals withDevTools [
        "antigravity"
        "cursor"
        # "figma"
        "firefox@developer-edition"
        "font-jetbrains-mono-nerd-font"
        "google-chrome@dev"
        "visual-studio-code"
      ]
      ++ lib.optionals withVirtualization [
        # "crystalfetch"
        (lib.mkIf (system == "aarch64-darwin") "orbstack")
        "utm"
        # "vmware-fusion"
      ]
      ++ lib.optionals withMediaServer [
        "font-el-messiri"
        "filebot"
        "fujitsu-scansnap-home"
        "istat-menus"
        "musicbrainz-picard"
        "plex-media-server"
      ]
      ++ lib.optionals withGaming [
        "es-de"
        "sony-ps-remote-play"
        (lib.mkIf (machineRole == "mediaServer") "steam")
      ]
      ++ lib.optionals withCommunication [
        "telegram"
        "zoom"
      ];

    global.autoUpdate = false;
    onActivation = {
      cleanup = "zap";
      extraFlags = ["--force"];
    };
  };

  networking = {
    applicationFirewall.enable = true;
    hostName = hostname;
    computerName = hostname;
    knownNetworkServices = [
      "Wi-Fi"
      "iPhone USB"
      "Thunderbolt Bridge"
    ];
  };

  # Enable Touch ID and Watch ID for sudo
  security.pam.services.sudo_local = {
    enable = true;
    reattach = true;
    touchIdAuth = true;
    watchIdAuth = true;
  };

  # Enable Tailscale
  services.tailscale = {
    enable = true;
    overrideLocalDns = true;
  };

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
        AppleIconAppearanceTheme = "ClearAutomatic";
        AppleInterfaceStyle = "Dark";
        AppleMeasurementUnits = "Centimeters";
        AppleTemperatureUnit = "Celsius";
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
