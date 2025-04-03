{ lib, ... }:
{
  options = {
    constants = {
      serverAddress = lib.mkOption {
        description = "VPN server address";
        type = lib.types.str;
        default = "147.45.240.98";
        readOnly = true;
      };
      wireguard = {
        tunnelPort = lib.mkOption {
          description = "Port used for tunnel";
          type = lib.types.port;
          default = 25565;
          readOnly = true;
        };
        port = lib.mkOption {
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
  };
}
