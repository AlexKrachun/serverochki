{ lib, config, pkgs, ... }:
let
  inherit (lib) getExe getExe';
  iptables = "${pkgs.iptables}/bin/iptables";
  wg = getExe' pkgs.wireguard-tools "wg";
  wgPort = config.constants.wireguard.port;
  inherit (config.constants.wireguard) subnetPrefix;
  addPeersScript =
    pkgs.writeScriptBin "add-peers.nu" ''
      #! ${getExe pkgs.nushell}

      def main [] {
        open ${config.sops.secrets.wireguard_peer_keys.path}
        | from yaml
        | values
        | enumerate
        | each {|el|
          let key = $el.item | ${wg} pubkey
          let i = $el.index + 2
          ${wg} set wg0 peer $key allowed-ips $"${subnetPrefix}.($i)/32"
        };
      }
    '';
in
{
  networking.nat.enable = true;
  networking.firewall.allowedUDPPorts = [ wgPort ];
  sops.secrets.wireguard_key = {
    owner = "root";
    mode = "0400";
    restartUnits = [ "wg-quick-wg0.service" ];
  };
  sops.secrets.wireguard_peer_keys = {
    owner = "root";
    mode = "0400";
    restartUnits = [ "wg-quick-wg0.service" ];
  };
  networking.wg-quick.interfaces = {
    wg0 = {
      address = [
        "${subnetPrefix}.1/24"
      ];
      autostart = true;
      listenPort = wgPort;

      # Public key: fnjS5SvMGwGQ0o3N+JpNndtZotzGmbrpR44fxsc1FEE=
      privateKeyFile = config.sops.secrets.wireguard_key.path;

      postUp = ''
        ${iptables} -A FORWARD -i %i -j ACCEPT
        ${iptables} -A FORWARD -o %i -j ACCEPT
        ${iptables} -t nat -A POSTROUTING -o ens3 -j MASQUERADE
        ${getExe addPeersScript}
      '';
      postDown = ''
        ${iptables} -D FORWARD -i %i -j ACCEPT
        ${iptables} -D FORWARD -o %i -j ACCEPT
        ${iptables} -t nat -D POSTROUTING -o ens3 -j MASQUERADE
      '';
    };
  };
}
