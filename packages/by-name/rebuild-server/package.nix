{
  writeShellApplication,
  nixos-rebuild,
  nix-output-monitor,
  self,
}:
let
  inherit (self.nixosConfigurations.sequoia.config) constants;
  sequoiaAddr = constants.serverAddress;
  pineAddr = constants.proxyAddress;
in
writeShellApplication {
  name = "rebuild-server";
  runtimeInputs = [
    nixos-rebuild
    nix-output-monitor
  ];
  text = ''
    nixos-rebuild switch \
      --flake ${self} \
      --use-remote-sudo \
      --use-substitutes \
      --target-host github-actions@${sequoiaAddr} \
      --log-format bar-with-logs

    nixos-rebuild switch \
      --flake ${self} \
      --use-remote-sudo \
      --use-substitutes \
      --target-host github-actions@${pineAddr} \
      --log-format bar-with-logs
  '';
}
