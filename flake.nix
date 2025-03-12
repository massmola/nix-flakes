{
  description = "Jupyter Notebook environment for NixOS";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { self, nixpkgs, ... }:
    let
      system = "x86_64-linux";
      pkgs = (
        import nixpkgs {
          inherit system;
          config = {
            permittedInsecurePackages = [
              "nodejs-16.20.2"
            ];
          };
        }
      );
    in
    {
      devShells.${system} = {
        jupiter = pkgs.mkShell {
          buildInputs = [
            pkgs.python3 # Provides Python
            pkgs.python3Packages.jupyter # Installs the jupyter command
            pkgs.python3Packages.notebook # Installs the notebook package
          ];

          shellHook = ''
            echo "Welcome to the Jupyter Notebook development environment!"
          '';
        };

        node16 = pkgs.mkShell {
          permittedInsecurePackages = [ "nodejs-16.20.2" ];
          buildInputs = [
            pkgs.nodejs_16
          ];

          shellHook = ''
            echo "Welcome to the Node.js 16 development environment!"
          '';
        };

        dotnet8 = pkgs.mkShell {
          buildInputs = [
            pkgs.dotnet-sdk_8 # .NET 8 SDK
          ];

          shellHook = ''
            echo "Welcome to the .NET 8 development environment!"
          '';
        };

      };
    };
}
