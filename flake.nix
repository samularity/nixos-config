{
  description = "my system config";

  #inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  inputs.nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  inputs.nixos-hardware.url = "github:NixOS/nixos-hardware/master";
  inputs.disko.url = "github:nix-community/disko";
  inputs.disko.inputs.nixpkgs.follows = "nixpkgs";
  inputs.kartei.url = "github:krebs/kartei";
  inputs.nixos-update-check.url = "github:samularity/nixos-versioncheck";
  inputs.nixos-update-check.inputs.nixpkgs.follows = "nixpkgs";

 outputs = { self, nixpkgs, nixpkgs-unstable, nixos-hardware, disko, kartei, nixos-update-check }:
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
          nixos-hardware.nixosModules.lenovo-thinkpad-x270
          kartei.nixosModules.retiolum
          nixos-update-check.nixosModules.default
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
