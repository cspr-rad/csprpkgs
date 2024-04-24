# Do not copy this! It is insecure. This is only okay because we are testing.
{
  system.activationScripts.agenixInstall.deps = [ "installSSHHostKeys" ];

  system.activationScripts.installSSHHostKeys.text = ''
    mkdir -p /etc/ssh
    (umask u=rw,g=r,o=r; cp ${./test-ssh-host-keys/nixos-test.pub} /etc/ssh/ssh_host_ed25519_key.pub)
    (
      umask u=rw,g=,o=
      cp ${./test-ssh-host-keys/nixos-test} /etc/ssh/ssh_host_ed25519_key
      touch /etc/ssh/ssh_host_rsa_key
    )
  '';
}
