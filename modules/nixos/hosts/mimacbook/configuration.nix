# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  # config,
  pkgs,
  lib,
  username,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  # Bootloader.
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  networking = {
    hostName = "mimacbook"; # Define your hostname.
    # wireless.enable = true;  # Enables wireless support via wpa_supplicant.
    interfaces.ens5.wakeOnLan.enable = true;

    # Configure network proxy if necessary
    # proxy.default = "http://user:password@proxy:port/";
    # proxy.noProxy = "127.0.0.1,localhost,internal.domain";

    # Enable networking
    networkmanager.enable = true;

    # Open ports in the firewall.
    # firewall.allowedTCPPorts = [ ... ];
    # firewall.allowedUDPPorts = [ ... ];
    # Or disable the firewall altogether.
    # firewall.enable = false;
  };

  # Set your time zone.
  time.timeZone = "Asia/Riyadh";

  i18n = {
    # Select internationalisation properties.
    defaultLocale = "en_US.UTF-8";

    extraLocaleSettings = {
      LC_ADDRESS = "en_US.UTF-8";
      LC_IDENTIFICATION = "en_US.UTF-8";
      LC_MEASUREMENT = "en_US.UTF-8";
      LC_MONETARY = "en_US.UTF-8";
      LC_NAME = "en_US.UTF-8";
      LC_NUMERIC = "en_US.UTF-8";
      LC_PAPER = "en_US.UTF-8";
      LC_TELEPHONE = "en_US.UTF-8";
      LC_TIME = "en_US.UTF-8";
    };
  };

  # Configure console keymap
  console.keyMap = "uk";

  # Enable sound with pipewire.
  security.rtkit.enable = true;
  services = {
    pulseaudio.enable = false;
    pipewire = {
      enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
      pulse.enable = true;
      # If you want to use JACK applications, uncomment this
      #jack.enable = true;

      # use the example session manager (no others are packaged yet so this is enabled by default,
      # no need to redefine it in your config for now)
      #media-session.enable = true;
    };
  };

  # Define a user account. Don't forget to set a password with 'passwd'.
  users.users.${username} = {
    isNormalUser = true;
    description = lib.strings.toSentenceCase username;
    extraGroups = ["networkmanager" "wheel"];
  };

  systemd = {
    # Workaround for GNOME autologin.
    #
    # ---
    # references:
    # - https://github.com/NixOS/nixpkgs/issues/103746#issuecomment-945091229
    services = {
      "getty@tty1".enable = false;
      "autovt@tty1".enable = false;
    };

    # Keep the system awake
    #
    # ---
    # references:
    # - https://discourse.nixos.org/t/prevent-laptop-from-suspending-when-lid-is-closed-if-on-ac/12630/6
    sleep.extraConfig = ''
      AllowSuspend=no
      AllowHibernation=no
      AllowHybridSleep=no
      AllowSuspendThenHibernate=no
    '';
  };

  # Install firefox.
  programs.firefox.enable = true;

  # Allow unfree packages
  nixpkgs.config = {
    allowUnfree = true;
    # Allow insecure Broadcom WiFi driver (needed for this hardware)
    permittedInsecurePackages = [
      "broadcom-sta-6.30.223.271-57-6.12.41"
    ];
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    #  wget
    wezterm
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  services = {
    xserver = {
      # Enable the X11 windowing system.
      enable = true;

      # Enable touchpad support (enabled by default in most desktopManager).
      # libinput.enable = true;

      # Configure keymap in X11
      xkb = {
        layout = "gb";
        variant = "mac";
      };
    };

    # Enable the GNOME Desktop Environment (using new options)
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
    # Enable CUPS to print documents.
    printing.enable = true;

    # Enable automatic login for the user.
    # displayManager.autoLogin = {
    #   enable = true;
    #   user = "mohammed";
    # };

    # Lock the screen when lid is closed.
    logind = {
      lidSwitch = "lock";
      extraConfig = ''
        HandlePowerKey=ignore
      '';
    };

    # Control the screen brightness when lid is closed.
    #
    # ---
    # references:
    # - https://www.reddit.com/r/NixOS/comments/14qa7d8/comment/jqo1cpw/?utm_source=share&utm_medium=web3x&utm_name=web3xcss&utm_term=1&utm_content=share_button
    # - https://github.com/waxlamp/nixos-config/blob/f8aecac4eb6e145f32d3c10f3842da18c217dd34/machines/kahless/configuration.nix#L171-L194
    # acpid = {
    #   enable = true;
    #   lidEventCommands =
    #     # bash
    #     ''
    #       if grep -qF 'close' /proc/acpi/button/lid/LID0/state; then
    #         # Set brightness to zero
    #         echo 0  > /sys/class/backlight/acpi_video0/brightness
    #       else
    #         # Reset the brightness
    #         echo 50  > /sys/class/backlight/acpi_video0/brightness
    #       fi
    #     '';
    #
    #   powerEventCommands = ''
    #     systemctl suspend
    #   '';
    # };

    # Enable the OpenSSH daemon.
    openssh = {
      enable = true;
      settings = {
        AllowGroups = ["wheel"];
        KbdInteractiveAuthentication = false;
        PasswordAuthentication = false;
        PermitRootLogin = "prohibit-password";
        UseDns = true;
        UsePAM = false;
        X11Forwarding = false;
      };
    };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?
}
