{ config, ... }:
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
      server_port = config.constants.wireguard.tunnelPort;
      mode = "udp_only";
      fast_open = true;
      method = "chacha20-ietf-poly1305";
    };
  };
  networking.firewall.allowedUDPPorts = [ config.constants.wireguard.tunnelPort ];
}
