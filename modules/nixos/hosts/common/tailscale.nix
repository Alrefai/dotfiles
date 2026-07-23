{role, ...}: {
  services.tailscale = {
    authKeyFile = "/persistent/secrets/tailscale/authkey";
    authKeyParameters = {ephemeral = false;};
    extraDaemonFlags = let
      stateDir = "/persistent/var/lib/tailscale";
    in [
      "--no-logs-no-support"
      "--statedir=${stateDir}"
      "--state=${stateDir}/tailscaled.state"
    ];
    extraUpFlags = ["--advertise-tags=tag:${role}" "--ssh"];
  };
}
