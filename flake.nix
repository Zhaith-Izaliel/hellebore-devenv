{
  description = "Zhaith Izaliel's Helix configuration.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    helix = {
      url = "github:helix-editor/helix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ flake-parts, helix, self, ... }:
  let
    version = "1.0.0";
  in
  flake-parts.lib.mkFlake { inherit inputs; } {
    systems = [ "x86_64-linux" "aarch64-darwin" "x86_64-darwin" ];

    perSystem = { pkgs, system, ... }: {
      devShells = {
        # nix develop
        default = pkgs.mkShell {
          nativeBuildInputs = with pkgs; [
            taplo
            toml2nix
          ];
        };
      };

      packages.default = pkgs.callPackages ./nix { inherit version; };
    };

    flake = rec {
      flakeModule = { withSystem, ... }: {
        flake.homeManagerModules.default = { pkgs, ... }: {
          imports =  [ ./nix/hm-module.nix ];

          programs.helix.zhaith-configuration.package =
            withSystem pkgs.stdenv.hostPlatform.system ({ config, ... }: config.packages.default);

            nixpkgs = {
              overlays = [
                overlays.default
              ];
            };
          };
        };
        overlays.default = helix.overlays.default;
      };
    };
  }

