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
    if git diff-tree --no-commit-id --name-only -r HEAD | grep -q '^flake\.lock$'; then
      flake_lock_changed=true
      command="boot"
      echo "flake.lock changed in the last commit. Performing '$command' and reboot."
    else
      flake_lock_changed=false
      command="switch"
      echo "flake.lock did not change. Performing '$command'."
    fi

    nixos-rebuild "$command" \
      --flake ${self} \
      --use-remote-sudo \
      --use-substitutes \
      --target-host github-actions@${sequoiaAddr} \
      --log-format bar-with-logs

    if [ "$flake_lock_changed" = true ]; then
      echo "Rebooting sequoia..."
      ssh github-actions@${sequoiaAddr} sudo systemctl reboot
    fi

    nixos-rebuild "$command" \
      --flake ${self} \
      --use-remote-sudo \
      --use-substitutes \
      --target-host github-actions@${pineAddr} \
      --log-format bar-with-logs

    if [ "$flake_lock_changed" = true ]; then
      echo "Rebooting pine..."
      ssh github-actions@${pineAddr} sudo systemctl reboot
    fi
  '';
}
