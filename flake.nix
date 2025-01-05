{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
  };
  outputs = { nixpkgs, ... }:
    let
      inherit (nixpkgs) lib;
      system = "x86_64-linux";
    in
    {
      nixosConfigurations.wayfarer = lib.nixosSystem {
        inherit system;

        modules = [
          ./configuration.nix
        ];
      };
    };
}
