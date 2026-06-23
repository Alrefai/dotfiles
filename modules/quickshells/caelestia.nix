{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    inputs.caelestia-shell.homeManagerModules.default
  ];
  home.packages = let
    extension = shortId: guid: {
      name = guid;
      value = {
        install_url = "https://addons.mozilla.org/en-US/firefox/downloads/latest/${shortId}/latest.xpi";
        installation_mode = "normal_installed";
      };
    };

    prefs = {
      # Check these out at about:config
      "extensions.autoDisableScopes" = 0;
      "extensions.pocket.enabled" = false;
      # ...
    };

    extensions = [
      # To add additional extensions, find it on addons.mozilla.org, find
      # the short ID in the url (like https://addons.mozilla.org/en-US/firefox/addon/!SHORT_ID!/)
      # Then go to https://addons.mozilla.org/api/v5/addons/addon/!SHORT_ID!/ to get the guid
      (extension "ublock-origin" "uBlock0@raymondhill.net")
      (extension "caelestiafox" "caelestiafox@caelestia.org")
      (extension "1password-x-password-manager" "{d634138d-c276-4fc8-924b-40a0ea21d284}")
      # ...
    ];
  in [
    pkgs.xfce.thunar
    pkgs.fastfetch
    pkgs.foot
    (
      pkgs.wrapFirefox
      inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.zen-browser-unwrapped
      {
        extraPrefs = lib.concatLines (
          lib.mapAttrsToList (
            name: value: ''lockPref(${lib.strings.toJSON name}, ${lib.strings.toJSON value});''
          )
          prefs
        );

        extraPolicies = {
          DisableTelemetry = true;
          ExtensionSettings = builtins.listToAttrs extensions;

          SearchEngines = {
            Default = "ddg";
            Add = [
              {
                Name = "nixpkgs packages";
                URLTemplate = "https://search.nixos.org/packages?query={searchTerms}";
                IconURL = "https://wiki.nixos.org/favicon.ico";
                Alias = "@np";
              }
              {
                Name = "NixOS options";
                URLTemplate = "https://search.nixos.org/options?query={searchTerms}";
                IconURL = "https://wiki.nixos.org/favicon.ico";
                Alias = "@no";
              }
              {
                Name = "NixOS Wiki";
                URLTemplate = "https://wiki.nixos.org/w/index.php?search={searchTerms}";
                IconURL = "https://wiki.nixos.org/favicon.ico";
                Alias = "@nw";
              }
              {
                Name = "noogle";
                URLTemplate = "https://noogle.dev/q?term={searchTerms}";
                IconURL = "https://noogle.dev/favicon.ico";
                Alias = "@ng";
              }
            ];
          };
        };
      }
    )
  ];
  programs = {
    quickshell.enable = true;
    caelestia = {
      enable = true;
      settings = {
        bar.status.showBattery = false;
        paths.wallpaperDir = "~/.local/share/wallpaper";
        session = {
          vimKeybinds = true;
          commands.logout = ["hyprctl" "dispatch" "exit"];
        };
        launcher.actionPrefix = "/";
      };
      cli.enable = true; # Also add caelestia-cli to path
    };
    fish.enable = true;
    zsh.initContent =
      lib.mkOrder 9000
      # sh
      ''
        # Custom colours

        echo -ne '\x1b[38;5;16m'  # Set colour to primary
        echo '     ______           __          __  _       '
        echo '    / ____/___ ____  / /__  _____/ /_(_)___ _ '
        echo '   / /   / __ `/ _ \/ / _ \/ ___/ __/ / __ `/ '
        echo '  / /___/ /_/ /  __/ /  __(__  ) /_/ / /_/ /  '
        echo '  \____/\__,_/\___/_/\___/____/\__/_/\__,_/   '
        echo -ne "\e[0m"

        \cat ${config.xdg.stateHome}/caelestia/sequences.txt 2> /dev/null

        command -v fastfetch >/dev/null && fastfetch \
          --key-padding-left 5  \
           -c ${config.xdg.configHome}/fastfetch/caelestia.jsonc
      '';
  };
  # services.hyprpolkitagent.enable = true;
  wayland.windowManager.hyprland = {
    enable = true;
    # set the Hyprland and XDPH packages to null to use the ones from the NixOS module
    package = null;
    portalPackage = null;
    extraConfig = ''
      $hypr = ~/.config/hypr
      $hl = $hypr/hyprland
      $cConf = ~/.config/caelestia

      # Variables (colours + other vars)
      exec = cp -L --no-preserve=mode --update=none $hypr/scheme/default.conf $hypr/scheme/current.conf
      source = $hypr/scheme/current.conf
      source = $hypr/variables.conf

      # User variables
      exec = mkdir -p $cConf && touch -a $cConf/hypr-vars.conf
      source = $cConf/hypr-vars.conf

      # Default monitor conf
      monitor = , preferred, auto, 1
      monitor = desc: Apple Computer Inc iMac 67C635F20AC39, preferred, 0x0, 1.5

      # Configs
      source = $hl/env.conf
      source = $hl/general.conf
      source = $hl/input.conf
      source = $hl/misc.conf
      source = $hl/animations.conf
      source = $hl/decoration.conf
      source = $hl/group.conf
      source = $hl/execs.conf
      source = $hl/rules.conf
      source = $hl/gestures.conf
      source = $hl/keybinds.conf

      # User configs
      exec = mkdir -p $cConf && touch -a $cConf/hypr-user.conf
      source = $cConf/hypr-user.conf
    '';
  };
}
