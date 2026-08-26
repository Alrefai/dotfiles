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

            # Lock tty1 session
            xargs -r loginctl terminate-session < <(
              /run/current-system/sw/bin/awk '$7 == "tty1" { print $1 }' \
                < <(loginctl list-sessions --no-legend)
            )
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

    /**
    Silence systemd-logind.service warning messages:
    `Requested suspend operation not supported, ignoring.`

    ---
    refs:
    - https://www.man7.org/linux/man-pages/man8/systemd-logind.service.8.html
    - https://www.man7.org/linux/man-pages/man5/logind.conf.5.html
    */
    logind.settings.Login = {
      HandleLidSwitch = "ignore";
      HandleSuspendKey = "ignore";
      HandleHibernateKey = "ignore";
      HandleSuspendKeyLongPress = "ignore";
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
