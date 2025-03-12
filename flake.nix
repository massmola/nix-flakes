{
  description = "Multiple dev shells example";

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
          buildInputs = [
            pkgs.python3
            pkgs.python3Packages.jupyter
            pkgs.python3Packages.notebook
          ];
          shellHook = ''
            echo "Welcome to the Jupyter Notebook environment!"
          '';
        };

        node = pkgs.mkShell {
          buildInputs = [
            nodePkgs.nodejs_16
          ];
          shellHook = ''
            echo "Welcome to the Node.js development environment!"
          '';
        };

        other = pkgs.mkShell {
          buildInputs = [
            pkgs.hello
          ];
          shellHook = ''
            echo "Welcome to the Hello world dev shell!"
          '';
        };
      };
    };
}
