{ ... }:
{
  imports = [
    ./shadowsocks.nix
    ./wireguard.nix
  ];

  nixpkgs.hostPlatform = "x86_64-linux";
  networking.hostName = "sequoia";
}
