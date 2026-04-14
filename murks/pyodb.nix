{
  description = "A flake for pyobd, an OBD-II compliant car diagnostic tool";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        packages.default = pkgs.python3Packages.buildPythonPackage rec {
          pname = "pyobd";
          version = "1.19";
          src = pkgs.fetchFromGitHub {
            owner = "barracuda-fsh";
            repo = "pyobd";
            rev = "v${version}";
            sha256 = "sha256-0000000000000000000000000000000000000000000000000000"; # replace with actual sha256
          };

          propagatedBuildInputs = with pkgs.python3Packages; [
            wxpython
            pyserial
            numpy
            tornado
            pint
          ];

          buildInputs = with pkgs; [
            hicolor-icon-theme
            python3Packages.pillow
          ];

          doCheck = false;
        };
      }
    );
}