_: {
  services = {
    acpid = {
      enable = true;

      # Control the screen brightness when lid is closed.
      #
      # ---
      # references:
      # - https://www.reddit.com/r/NixOS/comments/14qa7d8/comment/jqo1cpw/?utm_source=share&utm_medium=web3x&utm_name=web3xcss&utm_term=1&utm_content=share_button
      # - https://github.com/waxlamp/nixos-config/blob/f8aecac4eb6e145f32d3c10f3842da18c217dd34/machines/kahless/configuration.nix#L171-L194
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
