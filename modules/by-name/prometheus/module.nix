{ config, lib, ... }:
let
  wgInterface = "lwg";
  secretName = "${config.networking.hostName}VpnKey";
in
{
  options = {
    vpn = {
      address = lib.mkOption {
        description = "Local IP address for Liferooter's VPN";
        type = lib.types.str;
      };
    };
  };

  sops.secrets.${secretName} = {
    owner = "root";
    mode = "0400";
    restartUnits = [ "wireguard-${wgInterface}" ];
  };
  
  services.prometheus.exporters.node = {
    enable = true;
    listenAddress = config.vpn.address;
    openFirewall = true;
  };

  networking.wireguard = {
    enable = true;
    interfaces = {
      ${wgInterface} = {
        ips = [ "${config.vpn.address}/24" ];
        privateKeyFile = config.sops.secrets.${secretName}.path;

        peers = [
          {
            publicKey = "xjT3bxbeCAobw8zHHInCS2XKunH7erY7XOiJSd3BB2c=";
            allowedIPs = [ "10.200.200.0/24" ];
            endpoint = "liferooter.dev:51820";
            persistentKeepalive = 25;
          }
        ];
      };
    };
  };
}
