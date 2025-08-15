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

  config = {
    sops.secrets.${secretName} = {
      owner = "root";
      mode = "0400";
      restartUnits = [ "wireguard-${wgInterface}.service" ];
    };

    services.prometheus.exporters.node = {
      enable = true;
      listenAddress = config.vpn.address;
      openFirewall = true;
    };

    networking.wg-quick.interfaces.${wgInterface} = {
      address = [ "${config.vpn.address}/24" ];
      autostart = true;

      privateKeyFile = config.sops.secrets.${secretName}.path;

      peers = [
        {
          endpoint = "liferooter.dev:51820";
          allowedIPs = [ "10.200.200.0/24" ];
          publicKey = "xjT3bxbeCAobw8zHHInCS2XKunH7erY7XOiJSd3BB2c=";
        }
      ];
    };
  };
}
