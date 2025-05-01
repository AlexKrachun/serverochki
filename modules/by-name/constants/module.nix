{ lib, ... }:
let
  readTrimmed = file: lib.trim (builtins.readFile file);
in
{
  options = {
    constants = {
      proxyAddress = lib.mkOption {
        description = "Proxy server address";
        type = lib.types.str;
        default = readTrimmed ./proxy.txt;
        readOnly = true;
      };

      serverAddress = lib.mkOption {
        description = "VPN server address";
        type = lib.types.str;
        default = readTrimmed ./endpoint.txt;
        readOnly = true;
      };

      tunnelPort = lib.mkOption {
        description = "Port used for tunnel";
        type = lib.types.port;
        default = builtins.fromJSON (readTrimmed ./tunnel-port.txt);
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
        default = readTrimmed ./subnet.txt;
        readOnly = true;
      };
    };
  };
}
