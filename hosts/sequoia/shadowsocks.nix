{ config, ... }:
let
  inherit (config.constants) tunnelPort;
in
{
  sops.secrets.shadowsocksPassword = {
    owner = "root";
    mode = "0400";
    restartUnits = [ "shadowsocks-node-server.service" ];
  };
  services.shadowsocks-nodes.server = {
    role = "server";
    passwordFile = config.sops.secrets.shadowsocksPassword.path;
    config = {
      server = "::";
      server_port = tunnelPort;

      fast_open = true;

      mode = "tcp_and_udp";
      method = "chacha20-ietf-poly1305";
    };
  };
  networking.firewall = {
    allowedUDPPorts = [ tunnelPort ];
    allowedTCPPorts = [ tunnelPort ];
  };
}
