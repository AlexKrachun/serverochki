{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
  };
  outputs =
    inputs@{ self, nixpkgs, ... }:
    let
      inherit (nixpkgs) lib;
      modules = import ./modules/top-level/all-modules.nix { inherit lib; };
      eachSystem =
        f:
        lib.genAttrs lib.systems.flakeExposed (
          system:
          f {
            pkgs = import nixpkgs { inherit system; };
            inherit system;
          }
        );
      mkHost =
        hostname:
        lib.nixosSystem {
          modules = [
            ./hosts/${hostname}
          ] ++ modules.nixos;

          specialArgs = {
            inherit inputs self;
          };
        };
    in
    {
      nixosConfigurations = lib.flip lib.genAttrs mkHost [
        "pine"
        "sequoia"
      ];
      packages = eachSystem (
        { pkgs, ... }: import ./packages/top-level/all-packages.nix { inherit pkgs inputs self; }
      );
      devShell = eachSystem (
        { pkgs, system }:
        pkgs.mkShellNoCC {
          packages = [
            pkgs.nixd
            pkgs.sops
            pkgs.age
            pkgs.ssh-to-age
            pkgs.wireguard-tools
            self.packages.${system}.client-config
          ];
        }
      );
      formatter = eachSystem (system: inputs.nixpkgs-unstable.legacyPackages.${system}.nixfmt-tree);
    };
}
