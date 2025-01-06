{ config, pkgs, ... }:
let
  iptables = "${pkgs.iptables}/bin/iptables";
  wgPort = 443;
in
{
  networking.nat.enable = true;
  networking.firewall.allowedUDPPorts = [ wgPort ];
  sops.secrets.wireguard_key = {
    owner = "root";
    mode = "0400";
  };
  networking.wg-quick.interfaces = {
    wg0 = {
      address = [
        "10.200.200.1/24"
      ];
      autostart = true;
      listenPort = wgPort;

      # Public key: fnjS5SvMGwGQ0o3N+JpNndtZotzGmbrpR44fxsc1FEE=
      privateKeyFile = config.sops.secrets.wireguard_key.path;

      postUp = "${iptables} -A FORWARD -i %i -j ACCEPT; ${iptables} -A FORWARD -o %i -j ACCEPT; ${iptables} -t nat -A POSTROUTING -o ens3 -j MASQUERADE";
      postDown = "${iptables} -D FORWARD -i %i -j ACCEPT; ${iptables} -D FORWARD -o %i -j ACCEPT; ${iptables} -t nat -D POSTROUTING -o ens3 -j MASQUERADE";

      peers = [
        {
          allowedIPs = [ "10.200.200.2/32" ];
          publicKey = "AI7bkA+4kiwagCIsZKhW4/6KLs2KE5kLBU7iN5k9sAo=";
        }
      ];
    };
  };
}
