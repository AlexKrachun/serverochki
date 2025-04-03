{
  writeShellApplication,
  nixos-rebuild,
  nix-output-monitor,
  self,
}:
let
  sequoiaAddr = self.nixosConfigurations.sequoia.config.constants.serverAddress;
in
writeShellApplication {
  name = "rebuild-server";
  runtimeInputs = [
    nixos-rebuild
    nix-output-monitor
  ];
  text = ''
    nixos-rebuild switch \
      --fast \
      --flake . \
      --use-remote-sudo \
      --use-substitutes \
      --target-host ${sequoiaAddr} \
      --build-host ${sequoiaAddr} \
      --log-format internal-json \
      |& nom --json
  '';
}
