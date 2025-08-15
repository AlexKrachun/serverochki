{ ... }:
{
  imports = [
    ./shadowsocks.nix
  ];

  vpn.address = "10.200.127.6";

  nixpkgs.hostPlatform = "x86_64-linux";
  networking.hostName = "pine";
}
