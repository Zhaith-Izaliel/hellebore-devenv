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
    nixpkgs,
    ...
  }:
    flake-parts.lib.mkFlake {inherit inputs;} ({
      withSystem,
      config,
      ...
    }: let
      inherit (lib) types mkOption;
      lib = nixpkgs.lib;
    in {
      options.flake = {
        version = mkOption {
          default = "1.1.0";
          type = types.nonEmptyStr;
          readOnly = true;
          description = "Defines the version of the flake";
        };
      };

      config = {
        systems = ["x86_64-linux" "aarch64-darwin" "x86_64-darwin"];

        flake = rec {
          overlays.default = [
            inputs.nil.overlays.default
            (final: prev: {
              simple-completion-language-server = inputs.simple-completion-language-server.defaultPackage.${final.stdenv.hostPlatform.system};
            })
          ];

          homeManagerModules = {
            default = {...}: {
              imports = [
                homeManagerModules.helix-module
                homeManagerModules.zellij-module
              ];
            };

            helix-module = {pkgs, ...}: let
              home-module = import ./nix/hm-module.nix {
                package = withSystem pkgs.stdenv.hostPlatform.system ({config, ...}: config.packages.helix-config);
                helixPackage = withSystem pkgs.stdenv.hostPlatform.system ({config, ...}: config.packages.helix);
                overlays = overlays.default;
              };
            in {
              imports = [home-module];
            };

            zellij-module = {pkgs, ...}: let
              home-module = import ./nix/hm-module.nix {
                package = withSystem pkgs.stdenv.hostPlatform.system ({config, ...}: config.packages.zellij-config);
              };
            in {
              imports = [home-module];
            };
          };
        };

        perSystem = {
          pkgs,
          system,
          ...
        }: {
          packages = rec {
            fusion = pkgs.callPackage ./common/fusion.nix {};
            zellij-config = pkgs.callPackage ./nix {
              version = config.flake.version;
            };
            helix-config = pkgs.callPackage ./nix {
              inherit fusion;
              version = config.flake.version;
            };
            helix = inputs.helix.packages.${system}.default;
          };

          devShells = {
            # nix develop
            default = pkgs.mkShell {
              nativeBuildInputs = with pkgs; [
                toml2nix
              ];
            };
          };
        };
      };
    });
}
