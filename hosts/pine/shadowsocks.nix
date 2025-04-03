{ config, ... }:
let
  inherit (config.constants.wireguard) tunnelPort;
in
{
  sops.secrets.shadowsocksPassword = {
    owner = "root";
    mode = "0400";
    restartUnits = [ "shadowsocks-local.service" ];
  };
  services.shadowsocks-nodes.gateway = {
    role = "local";
    passwordFile = config.sops.secrets.shadowsocksPassword.path;
    config = {
      server = config.constants.serverAddress;
      server_port = tunnelPort;
      fast_open = true;
      method = "chacha20-ietf-poly1305";

      local_address = "::";
      local_port = tunnelPort;
    };
  };
}
