{
  description = "My dev shells";

  inputs.defaultpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  inputs.nodejs16pkgs.url = "github:NixOS/nixpkgs/nixos-23.05";

  outputs =
    {
      self,
      defaultpkgs,
      nodejs16pkgs,
      ...
    }:
    let
      system = "x86_64-linux";

      pkgs = import defaultpkgs {
        inherit system;
      };

      nodePkgs = import nodejs16pkgs {
        inherit system;
        config = {
          permittedInsecurePackages = [ "nodejs-16.20.2" ];
        };
      };
    in
    {
      devShells.${system} = {
        jupiter = pkgs.mkShell {
          buildInputs = with pkgs; [
            (python3.withPackages (
              ps: with ps; [
                ipython
                jupyter
                notebook
                numpy
                pandas
                matplotlib
                pytest
                h5py
              ]
            ))
          ];
          shellHook = ''
            echo "Welcome to the Jupyter Notebook environment!"
          '';
        };

        node = pkgs.mkShell {
          buildInputs = [
            nodePkgs.nodejs_16
            # nodePkgs.nodePackages."@angular/cli"
          ];
          shellHook = ''
            echo "Welcome to the Node.js 16 development environment!"
          '';
        };
      };
    };
}
