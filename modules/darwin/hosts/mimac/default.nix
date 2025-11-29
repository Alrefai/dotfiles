{username, ...}: {
  homebrew.casks = [
    "font-aref-ruqaa"
    "font-rakkas"
  ];
  networking.knownNetworkServices = ["Ethernet"];
  services.openssh = {
    enable = true;
    extraConfig = ''
      PermitRootLogin no
      PasswordAuthentication no
      PermitEmptyPasswords no
      KbdInteractiveAuthentication no
      UsePAM no
      X11Forwarding no
    '';
  };
  users.users.${username}.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAz09SftQ86+tx7dvrS6+EKVTcsRCyDyK/zn81C1tHIH mohammed@1password"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIONVn/zRfjdUhGIjE9wLNq7tKqOJztSwCwVTJhxcZ+dx miphonex@shortcuts"
    "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBMnZQEthxvpozo9q9w9Mt5u/MaxZXuR5kImVrjmcUv/T4KxuvQ0A6Ku9hx7UF0JaoTW7qmbyaqZFkU0dF9uHEwE= miphonex@blink"
    "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBPmcGMAxYY2M7MO2IBlC/EdPHa2Hki//13LzLw599jE4hpHnKb/AzOUc/7qHImaxIshfjj0+gh6p7aT41lYfvu0= mipadpro@blink"
    "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBBcM3U02jIVFNCYRClYRQmB6fK0GIQwL5UQGk/1A/QnSvmouJysLgpdf5vPSSKp6IyYYtebuLIRHGB6GCaDy7T0= mim2macbookair@transmit"
  ];
}
