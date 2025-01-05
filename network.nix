{ config, ... }:
{
  networking = {
    hostName = "wayfarer";
    nameservers = [ "1.1.1.1" ];
  };
  systemd.network = {
    enable = true;

    networks.main = {
      matchConfig.Name = "ens3";
      address = [ "95.164.2.198/32" ];
      dns = config.networking.nameservers;
      routes = [{
        Gateway = "95.164.2.1";
        GatewayOnLink = true;
      }];
    };
  };
  networking.useDHCP = false;
}
