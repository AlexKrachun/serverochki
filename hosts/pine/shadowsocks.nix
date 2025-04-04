{ config, ... }:
let
  inherit (config.constants) tunnelPort wgPort;
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

      method = "chacha20-ietf-poly1305";

      locals = [
        {
          protocol = "tunnel";

          forward_address = "127.0.0.1";
          forward_port = wgPort;

          local_address = "0.0.0.0";
          local_port = tunnelPort;

          fast_open = true;

          mode = "udp_only";
        }
      ];
    };
  };
  networking.firewall.allowedUDPPorts = [ tunnelPort ];
}
