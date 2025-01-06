{ config, ... }:
{
  networking = {
    hostName = "wayfarer";
    nameservers = [ config.constants.dns ];
  };
  systemd.network = {
    enable = true;

    networks.main = {
      matchConfig.Name = "ens3";
      address = [ "${config.constants.address}/32" ];
      dns = config.networking.nameservers;
      routes = [{
        Gateway = "95.164.2.1";
        GatewayOnLink = true;
      }];
    };
  };
  networking.useDHCP = false;
}
