_: {
  preservation = {
    enable = true;

    preserveAt."/persistent" = {
      directories = [
        {
          directory = "/var/lib/nixos";
          inInitrd = true;
          how = "symlink";
          configureParent = true;
          createLinkTarget = true;
        }
        {
          directory = "/var/lib/systemd/timers";
          how = "symlink";
          configureParent = true;
          createLinkTarget = true;
        }
        {
          directory = "/var/tmp";
          how = "symlink";
          configureParent = true;
          createLinkTarget = true;
          mode = "1777";
        }
      ];

      files = [
        {
          file = "/etc/machine-id";
          inInitrd = true;
        }
        {
          file = "/var/lib/systemd/credential.secret";
          mode = "0400";
        }
        {
          file = "/var/lib/systemd/random-seed";
          how = "symlink";
          inInitrd = true;
          configureParent = true;
        }
      ];
    };
  };

  # systemd-machine-id-commit.service would fail, but it is not relevant
  # in this specific setup for a persistent machine-id so we disable it
  systemd.suppressedSystemUnits = ["systemd-machine-id-commit.service"];
}
