{
  description = "Jupyter Notebook environment for NixOS";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { self, nixpkgs, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        buildInputs = [
          pkgs.python3 # Provides Python
          pkgs.python3Packages.jupyter # Installs the jupyter command
          pkgs.python3Packages.notebook # Installs the notebook package
        ];

        shellHook = ''
          echo "Welcome to the Jupyter Notebook development environment!"
        '';
      };
    };
}
