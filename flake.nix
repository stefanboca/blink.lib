{
  description = "Shared library for blink.* neovim plugins";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "x86_64-darwin"
        "aarch64-linux"
        "aarch64-darwin"
      ];

      perSystem =
        {
          self',
          pkgs,
          lib,
          ...
        }:
        {
          packages =
            let
              fs = lib.fileset;
              version = "0.1.0";
            in
            {
              blink-lib = pkgs.vimUtils.buildVimPlugin {
                pname = "blink.lib";
                inherit version;
                src = fs.toSource {
                  root = ./.;
                  fileset = fs.difference ./. (
                    fs.unions (
                      lib.filter builtins.pathExists [
                        ./flake.nix
                        ./flake.lock
                      ]
                    )
                  );
                };
              };

              default = self'.packages.blink-lib;
            };
        };
    };
}
