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
        jupyter = pkgs.mkShell {
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
                librosa
                lightgbm
                xgboost
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
            pkgs.dotnet-sdk_8 # .NET 8 SDK
            pkgs.cyclonedx-dotnet # Add CycloneDX .NET tool
          ];

          environment.sessionVariables = {
            DOTNET_ROOT = "${pkgs.dotnet-sdk}/share/dotnet";
          };

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

        # PHP devshell
        php = pkgs.mkShell {
          # Define the packages to include in this shell
          buildInputs = with pkgs; [
            php # PHP interpreter (should include Apache SAPI by default in shells)
          ];

          # Set environment variables (optional)
          # For example, you might set a specific PHP configuration directory
          shellHook = ''
            echo "PHP development shell active."
          '';

          # A brief description of the shell
          meta = with pkgs.lib; {
            description = "A development shell for PHP projects with Apache.";
          };
        };
      };
    };
}
