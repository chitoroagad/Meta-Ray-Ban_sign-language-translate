{
  description = "Python venv development env in nix";

  inputs = {
    utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    utils,
    ...
  }:
    utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {inherit system;};
      pythonPackages = pkgs.python310Packages;
    in {
      devShells.default = pkgs.mkShell {
        name = "python-venv";
        venvDir = "./.venv";
        buildInputs = [
          # A Python interpreter including the 'venv' module is required to bootstrap
          # the environment.
          pythonPackages.python

          # This executes some shell code to initialize a venv in $venvDir before
          # dropping into the shell
          pythonPackages.venvShellHook

          # Those are dependencies that we would like to use from nixpkgs, which will
          # add them to PYTHONPATH and thus make them accessible from within the venv.
          pythonPackages.numpy
        ];

        # Run this command, only after creating the virtual environment
        postVenvCreation = ''
          unset SOURCE_DATE_EPOCH
          pip install --upgrade pip
          pip install -r requirements.txt
        '';

        # Now we can execute any commands within the virtual environment.
        # This is optional and can be left out to run pip manually.
        postShellHook = ''
          # allow pip to install wheels
          unset SOURCE_DATE_EPOCH
        '';

        # Dependency for NixOS
        LD_LIBRARY_PATH = ''${pkgs.stdenv.cc.cc.lib}/lib/:${pkgs.libGL}/lib/:${pkgs.glib.out}/lib:/run/opengl-driver/lib/'';
      };
    });
}