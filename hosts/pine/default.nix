{ ... }:
{
  imports = [
    ./shadowsocks.nix
  ];

  nixpkgs.hostPlatform = "x86_64-linux";
  networking.hostName = "pine";
}
