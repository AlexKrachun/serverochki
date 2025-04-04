{ lib, ... }:
{
  options = {
    constants = {
      proxyAddress = lib.mkOption {
        description = "Proxy server address";
        type = lib.types.str;
        default = "193.160.209.85";
        readOnly = true;
      };

      serverAddress = lib.mkOption {
        description = "VPN server address";
        type = lib.types.str;
        default = "80.64.17.37";
        readOnly = true;
      };

      tunnelPort = lib.mkOption {
        description = "Port used for tunnel";
        type = lib.types.port;
        default = 25565;
        readOnly = true;
      };

      wgPort = lib.mkOption {
        description = "Port used for Wireguard";
        type = lib.types.port;
        default = 443;
        readOnly = true;
      };
      
      subnetPrefix = lib.mkOption {
        description = "Prefix of Wireguard subnet";
        type = lib.types.str;
        default = "10.200.200";
        readOnly = true;
      };
    };
  };
}
