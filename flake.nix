{
  description = "Zhaith Izaliel's Helix configuration.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    helix = {
      url = "github:helix-editor/helix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nil = {
      url = "github:oxalica/nil";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    simple-completion-language-server = {
      url = "github:estin/simple-completion-language-server";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {
    flake-parts,
    nil,
    simple-completion-language-server,
    ...
  }: let
    version = "1.0.0";
  in
    flake-parts.lib.mkFlake {inherit inputs;} ({withSystem, ...}: {
      systems = ["x86_64-linux" "aarch64-darwin" "x86_64-darwin"];

      perSystem = {
        pkgs,
        system,
        ...
      }: {
        devShells = {
          # nix develop
          default = pkgs.mkShell {
            nativeBuildInputs = with pkgs; [
              taplo
              toml2nix
            ];
          };
        };

        packages = rec {
          default = pkgs.callPackage ./nix {inherit version fusion;};
          helix = inputs.helix.packages.${system}.default;
          fusion = pkgs.callPackage ./nix/dependencies/fusion.nix {};
        };
      };

      flake = rec {
        homeManagerModules.default = {pkgs, ...}: let
          home-module = import ./nix/hm-module.nix {
            package = withSystem pkgs.stdenv.hostPlatform.system ({config, ...}: config.packages.default);
            helixPackage = withSystem pkgs.stdenv.hostPlatform.system ({ config, ... }: config.packages.helix);
          };
        in {
          imports = [home-module];

          nixpkgs = {
            overlays = overlays.default;
          };
        };

        overlays.default = [
          nil.overlays.default
          (final: prev: {
            simple-completion-language-server = simple-completion-language-server.defaultPackage.${final.stdenv.hostPlatform.system};
          })
        ];
      };
    });
}
