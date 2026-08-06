_: {
  services = {
    /**
    Control the screen brightness when lid is closed.

    ---
    refs:
    - https://wiki.archlinux.org/title/Acpid
    */
    acpid = {
      enable = true;

      lidEventCommands =
        # bash
        ''
          if grep -qF 'close' /proc/acpi/button/lid/LID0/state; then
            # Set brightness to zero
            echo 0 > /sys/class/backlight/acpi_video0/brightness
          else
            # Reset the brightness
            echo 15 > /sys/class/backlight/acpi_video0/brightness
          fi
        '';
    };

    /**
    Hide agetty printed issue and "login:" prompt line from the console.

    ---
    refs:
    - https://wiki.archlinux.org/title/Getty#Virtual_console
    - https://wiki.archlinux.org/title/Silent_boot#agetty
    */
    getty = {
      extraArgs = [
        "--skip-login"
        "--nonewline"
        "--noissue"
        "--noreset"
        "--noclear"
      ];
    };

    openssh = {
      enable = true;
      hostKeys = [
        {
          path = "/persistent/secrets/ssh/host/ssh_host_ed25519_key";
          type = "ed25519";
        }
      ];
      openFirewall = true;
      settings = {
        AllowGroups = ["wheel"];
        KbdInteractiveAuthentication = false;
        MaxAuthTries = 3;
        PasswordAuthentication = false;
        PermitRootLogin = "no";
        UseDns = true;
        UsePAM = false;
        X11Forwarding = false;
      };
    };
  };

  systemd.services.screen-off = {
    description = "Turn off screen when lid is closed after boot";
    enableStrictShellChecks = true;
    requires = ["acpid.service"];
    serviceConfig.Type = "oneshot";
    script =
      # bash
      ''
        if grep -qF 'close' /proc/acpi/button/lid/LID0/state; then
          # Set brightness to zero
          echo 0 > /sys/class/backlight/acpi_video0/brightness
        fi
      '';
    wantedBy = ["multi-user.target"];
  };
}
