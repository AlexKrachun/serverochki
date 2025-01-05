{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
  };
  outputs = { self, nixpkgs, ... }@inputs:
    let
      inherit (nixpkgs) lib;
      eachSystem = lib.genAttrs lib.systems.flakeExposed;
    in
    {
      nixosConfigurations.wayfarer = lib.nixosSystem {
        system = "x86_64-linux";

        modules = [
          ./configuration.nix
        ];

        specialArgs = {
          inherit inputs self;
        };
      };
      devShell = eachSystem (system:
        let
          pkgs = import nixpkgs { inherit system; };
        in
        pkgs.mkShellNoCC {
          packages = (with pkgs; [
            nixd sops age
            ssh-to-age wireguard-tools
          ]) ++ [(
            pkgs.writeShellApplication {
              name = "rebuild-nixos";

              runtimeInputs = [
                pkgs.nixos-rebuild
              ];

              text = ''
                nixos-rebuild switch --fast --flake . --target-host 95.164.2.198 --build-host 95.164.2.198 --use-remote-sudo --use-substitutes
              '';
            }
          )];
        });
    };

}
