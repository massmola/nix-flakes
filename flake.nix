{
  description = "My dev shells";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  inputs.nodejs16pkgs.url = "github:NixOS/nixpkgs/nixos-23.05";
  # Input for the legacy aiagents shell (Python 3.7)
  inputs.aiagents-nixpkgs.url = "github:NixOS/nixpkgs/nixos-21.11";

  outputs =
    {
      self,
      nixpkgs,
      nodejs16pkgs,
      aiagents-nixpkgs, # <-- Add new input here
      ...
    }:
    let
      system = "x86_64-linux";

      # Pkgs for most shells (from nixos-unstable)
      pkgs = import nixpkgs {
        inherit system;
      };

      # Pkgs for node16 shell (from nixos-23.05)
      nodePkgs = import nodejs16pkgs {
        inherit system;
        config = {
          permittedInsecurePackages = [ "nodejs-16.20.2" ];
        };
      };

      # Pkgs for aiagents shell (from nixos-21.11)
      aiagentsPkgs = import aiagents-nixpkgs { inherit system; };
      aiagentsPy = aiagentsPkgs.python37;

      # --- Definition for the new aiagents shell ---
      aiagentsShell = aiagentsPkgs.mkShell {
        name = "iap-py37";

        # Nix-provided tools & libs (no nix python packages to avoid Tk/Tcl surprises)
        packages = with aiagentsPkgs; [
          aiagentsPy
          clingo
          fast-downward # if this fails on your platform, comment it out
          z3
          graphviz # `dot` for python-graphviz
          git
          pkg-config
          libffi
          openssl
          cairo
          freetype
          libpng
          gobject-introspection
          zlib
          libxml2
          libxslt

          # Build tools in case some wheels are missing for Py3.7
          cmake
          gnumake
          gcc
          which
          coreutils
        ];

        # Helpful runtime lib path for assorted wheels
        LD_LIBRARY_PATH = aiagentsPkgs.lib.makeLibraryPath [
          aiagentsPkgs.stdenv.cc.cc
          aiagentsPkgs.zlib
          aiagentsPkgs.libxml2
          aiagentsPkgs.libxslt
          aiagentsPkgs.freetype
          aiagentsPkgs.libpng
          aiagentsPkgs.cairo
          aiagentsPkgs.openssl
          aiagentsPkgs.libffi
        ];

        shellHook = ''
          set -euo pipefail

          VENV_DIR="$PWD/.venv-py37-iap" # Using a distinct venv dir
          # IMPORTANT: Must use the coreutils from the correct nixpkgs
          PY="$(${aiagentsPkgs.coreutils}/bin/readlink -f "$(command -v python)")"

          if [ ! -d "$VENV_DIR" ]; then
            echo "→ Creating virtualenv at $VENV_DIR (Python $("$PY" -V))"
            "$PY" -m venv "$VENV_DIR"

            echo "→ Upgrading pip/wheel"
            "$VENV_DIR/bin/python" -m pip install --upgrade pip wheel setuptools

            # On Py3.7 many wheels are gone; allow building from source if needed
            export PIP_ONLY_BINARY=      # unset wheel-only
            export PIP_NO_BUILD_ISOLATION=0

            echo "→ Installing Python dependencies for Py3.7 …"
            "$VENV_DIR/bin/python" -m pip install \
              "gym[classic_control]==0.26.2" \
              "joblib" \
              "matplotlib<3.8" \
              "nltk" \
              "pandas<2.0" \
              "pgmpy<0.1.23" \
              "graphviz" \
              "scikit-learn<1.3" \
              "seaborn<0.13" \
              "pyglet<2" \
              "tensorflow<=2.10.*" \
              "z3-solver" \
              "jupyter"

            echo "→ Installing course repo (wumpus) with gym extra"
            "$VENV_DIR/bin/python" -m pip install \
              "git+https://gitlab.inf.unibz.it/iap2025/wumpus-tessaris.git@master#egg=wumpus[gym]"
          fi

          # Activate venv every session
          . "$VENV_DIR/bin/activate"

          echo
          echo "✅ iap (Py3.7) dev shell ready."
          echo "   Virtualenv: $VIRTUAL_ENV"
          python -c "import sys; print('Python:', sys.version.split()[0])"

          # Quick import health check
          python - <<'PY'
import importlib
mods = [
  "tensorflow","gym","joblib","matplotlib","nltk","pandas",
  "pgmpy","graphviz","sklearn","seaborn","pyglet","z3"
]
for m in mods:
    try:
        importlib.import_module(m)
        print(f" - {m}: OK")
    except Exception as e:
        print(f" - {m}: MISSING ({e.__class__.__name__}: {e})")
PY
        '';
      };
      # --- End of aiagents shell definition ---

    in
    {
      devShells.${system} = {
        # Jupyter Notebook devshell
        py = pkgs.mkShell {
          buildInputs = with pkgs; [
            pkgs.bashInteractive
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
                seaborn
                librosa
                lightgbm
                xgboost
                scikit-learn
                tqdm
                imbalanced-learn
                graphviz
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

        # --- Add the new shell to the outputs ---
        aiagents = aiagentsShell;

      };
    };
}