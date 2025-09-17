{
  description = "my system config";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
  inputs.nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  inputs.nixos-hardware.url = "github:NixOS/nixos-hardware/master";
  inputs.disko.url = "github:nix-community/disko";
  inputs.disko.inputs.nixpkgs.follows = "nixpkgs";
  inputs.nixos-versioncheck.url = "github:samularity/nixos-versioncheck";
  inputs.nixos-versioncheck.inputs.nixpkgs.follows = "nixpkgs";

 outputs = { self, nixpkgs, nixpkgs-unstable, nixos-hardware, disko, nixos-versioncheck }:
    let
      system = "x86_64-linux";
      overlay-unstable = final: prev: {
        unstable = import nixpkgs-unstable {
          inherit system;
          config.allowUnfree = true;
        };
      };
    in {
      nixosConfigurations.murks = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          # Overlays-module makes "pkgs.unstable" available in configuration.nix
          ({ config, pkgs, ... }: { nixpkgs.overlays = [ overlay-unstable ]; })
          ./common.nix
          ./murks/configuration.nix
          nixos-versioncheck.nixosModules.x86_64-linux.default
          nixos-hardware.nixosModules.lenovo-thinkpad-x270
        ];
      };

      nixosConfigurations.box = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          # Overlays-module makes "pkgs.unstable" available in configuration.nix
          ({ config, pkgs, ... }: { nixpkgs.overlays = [ overlay-unstable ]; })
          disko.nixosModules.disko
          ./common.nix
          ./box/configuration.nix
        ];
        };

      nixosConfigurations.powerbox = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          # Overlays-module makes "pkgs.unstable" available in configuration.nix
          ({ config, pkgs, ... }: { nixpkgs.overlays = [ overlay-unstable ]; })
          disko.nixosModules.disko
          ./common.nix
          ./powerbox/configuration.nix
        ];
        };

    };
}
