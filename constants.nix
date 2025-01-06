{ lib, ... }:
{
  options = {
    constants = {
      address = lib.mkOption {
        description = "Server IP address";
        type = lib.types.str;
        default = "95.164.2.198";
        readOnly = true;
      };
      dns = lib.mkOption {
        description = "DNS server address";
        type = lib.types.str;
        default = "1.1.1.1";
        readOnly = true;
      };
      wireguard = {
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
