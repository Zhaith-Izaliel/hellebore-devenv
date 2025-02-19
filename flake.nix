{
  description = "Zhaith Izaliel's Helix configuration.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
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
    ctags-lsp = {
      url = "github:netmute/ctags-lsp";
      flake = false;
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
      local-overlays = {
        helix = import ./helix/nix/overlay.nix {inherit inputs;};
      };
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
          overlays.helix = [
            inputs.nil.overlays.default
            local-overlays.helix
          ];

          homeManagerModules = {
            default = {...}: {
              imports = [
                homeManagerModules.helix
                homeManagerModules.zellij
                homeManagerModules.yazi
                homeManagerModules.erdtree
              ];
            };

            erdtree = {...}: {
              imports = [./erdtree/nix/hm-module.nix];
            };

            helix = {pkgs, ...}: let
              home-module = import ./helix/nix/hm-module.nix {
                package = withSystem pkgs.stdenv.hostPlatform.system ({config, ...}: config.packages.helix-config);
                helixPackage = withSystem pkgs.stdenv.hostPlatform.system ({config, ...}: config.packages.helix);
                overlays = overlays.helix;
              };
            in {
              imports = [home-module];
            };

            zellij = {pkgs, ...}: let
              home-module = import ./zellij/nix/hm-module.nix {
                package = withSystem pkgs.stdenv.hostPlatform.system ({config, ...}: config.packages.zellij-config);
              };
            in {
              imports = [home-module];
            };

            yazi = {pkgs, ...}: let
              home-module = import ./yazi/nix/hm-module.nix {
                package = withSystem pkgs.stdenv.hostPlatform.system ({config, ...}: config.packages.yazi-config);
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

            helix = inputs.helix.packages.${system}.default;

            helix-config = pkgs.callPackage ./helix/nix {
              inherit fusion;
              version = config.flake.version;
            };

            yazi-config = pkgs.callPackage ./yazi/nix {
              inherit fusion;
              version = config.flake.version;
            };

            zellij-config = pkgs.callPackage ./zellij/nix {
              version = config.flake.version;
            };
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
