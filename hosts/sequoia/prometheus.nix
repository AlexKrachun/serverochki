{ config, ... }:
{
  services.prometheus.exporters.wireguard = {
    enable = true;
    interfaces = [ "wg0" ];
    listenAddress = config.vpn.address;
    latestHandshakeDelay = true;
    openFirewall = true;
  };
}
