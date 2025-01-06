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
          inherit (self.nixosConfigurations.wayfarer.config) constants;
          serverIP = constants.address;
        in
        pkgs.mkShellNoCC {
          packages = (with pkgs; [
            nixd
            sops
            age
            ssh-to-age
            wireguard-tools
          ]) ++ [
            (
              pkgs.writeShellApplication {
                name = "rebuild-nixos";

                runtimeInputs = with pkgs; [
                  nixos-rebuild
                  nix-output-monitor
                ];

                text = ''
                  nixos-rebuild switch \
                    --fast \
                    --flake . \
                    --target-host ${serverIP} \
                    --build-host ${serverIP} \
                    --use-remote-sudo \
                    --use-substitutes \
                    --log-format internal-json \
                    |& nom --json
                '';
              }
            )
            (
              let
                sops = lib.getExe pkgs.sops;
                wg = lib.getExe' pkgs.wireguard-tools "wg";
                git = lib.getExe pkgs.git;
              in
              pkgs.writeScriptBin "client-config" ''
                #! ${lib.getExe pkgs.nushell}

                def main [ name: string ] {
                  let secrets = ${git} rev-parse --show-toplevel
                    | $"($in)/secrets/wayfarer.yml"
                    | ${sops} decrypt $in
                    | from yaml

                  let server_pubkey = $secrets.wireguard_key
                    | ${wg} pubkey

                  let found_peers = $secrets.wireguard_peer_keys
                    | from yaml
                    | transpose name key
                    | enumerate
                    | flatten
                    | where ($it.name == $name)

                  if ($found_peers | is-empty) {
                    print --stderr $"Peer ($name) doesn't exist"
                    exit 1
                  }

                  let peer = $found_peers | first
                  
                  $"
                [Interface]
                PrivateKey = ($peer.key)
                Address = ${constants.wireguard.subnetPrefix}.($peer.index + 2)/32
                DNS = ${constants.dns}

                [Peer]
                PublicKey = ($server_pubkey)
                AllowedIPs = 0.0.0.0/0
                Endpoint = ${serverIP}:${toString constants.wireguard.port}
                  " | str trim | print
                }
              ''
            )
          ];
        });
    };

}
