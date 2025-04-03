{ lib, inputs, ... }:
{
  imports = [
    inputs.sops-nix.nixosModules.sops
  ];
  config = {

    sops = {
      defaultSopsFile = lib.mkDefault ./common.yml;
      age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
    };
  };
}
