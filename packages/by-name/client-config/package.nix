{
  lib,
  writeScriptBin,
  git,
  nushell,
  sops,
  wireguard-tools,

  self,
}:
let
  inherit (self.nixosConfigurations.pine.config) constants;
in
writeScriptBin "client-config" ''
  #! ${lib.getExe nushell}

  def main [ name: string ] {
    let repo_root = ${lib.getExe git} rev-parse --show-toplevel

    let server_pubkey = ${lib.getExe sops} decrypt $"($repo_root)/wireguard-server.yml"
      | from yaml
      | get wireguardKey
      | ${lib.getExe' wireguard-tools "wg"} pubkey

    let found_peers = ${lib.getExe sops} decrypt $"($repo_root)/wireguard-clients.yml"
      | from yaml
      | transpose name key
      | enumerate
      | flatten
      | where ($it.name == $name)

    if ($found_peers | is-empty) {
      print --stderr $"Peer ($name) doesn't exist"
      exit 1
    }

    let peer = $found_peers | first

    $"
  [Interface]
  PrivateKey = ($peer.key)
  Address = ${constants.wireguard.subnetPrefix}.($peer.index + 2)/32
  DNS = 1.1.1.1

  [Peer]
  PublicKey = ($server_pubkey)
  AllowedIPs = 0.0.0.0/0
  Endpoint = 193.160.209.85:${toString constants.wireguard.tunnelPort}
    " | str trim | print
  }
''
