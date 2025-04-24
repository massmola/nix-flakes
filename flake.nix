# flake.nix
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
        # Jupyter Notebook devshell
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
                scikit-learn
                seaborn
              ]
            ))
          ];
          shellHook = ''
            echo "Welcome to the Jupyter Notebook environment!"
          '';
        };

        # .NET 8 devshell
        dotnet8 = pkgs.mkShell {
          buildInputs = [
            pkgs.dotnet-sdk_8  # .NET 8 SDK
          ];

          shellHook = ''
            echo "Welcome to the .NET 8 development environment!"
          '';
        };

        # Node.js 16 devshell
        node16 = pkgs.mkShell {
          buildInputs = [
            nodePkgs.nodejs_16
            # nodePkgs.nodePackages."@angular/cli"
          ];
          shellHook = ''
            echo "Welcome to the Node.js 16 development environment!"
          '';
        };

        # PHP devshell (added)
        php = pkgs.mkShell { # Added a name 'php' for this devshell
          # Define the packages to include in this shell
          buildInputs = with pkgs; [
            # Core PHP package
            php

            # Common PHP extensions (add/remove as needed)
            # You can find more extensions by searching the Nix Packages manual
            # or using `nix search php82Extensions.<extension_name>` (replace 82 with your PHP version)
            php.extensions.curl      # Enable cURL support
            php.extensions.gd        # Enable GD library support for image manipulation
            php.extensions.intl      # Enable Internationalization functions
            php.extensions.mysqli    # Enable MySQL Improved Extension
            php.extensions.pdo       # Enable PHP Data Objects
            php.extensions.pdo_mysql # Enable PDO MySQL driver
            php.extensions.zip       # Enable Zip archive support
          ];

          # Set environment variables (optional)
          # For example, you might set a specific PHP configuration directory
          # shellHook = ''
          #   export PHP_INI_SCAN_DIR="$PWD/php.d"
          #   echo "PHP development shell active."
          # '';

          # A brief description of the shell
          meta = with pkgs.lib; {
            description = "A development shell for PHP projects.";
          };
        };
      };
    };
}
