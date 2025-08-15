{ ... }:
{
  imports = [
    ./shadowsocks.nix
    ./wireguard.nix
  ];

  vpn.address = "10.200.127.7";

  nixpkgs.hostPlatform = "x86_64-linux";
  networking.hostName = "sequoia";
}
