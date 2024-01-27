{
  description = "Zhaith Izaliel's Helix configuration.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nil.url = "github:oxalica/nil";
  };

  outputs = inputs@{ flake-parts, nil, self, ... }:
  let
    version = "1.0.0";
  in
  flake-parts.lib.mkFlake { inherit inputs; } ({ withSystem, ... }: {
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

    packages = rec {
      default = pkgs.callPackage ./nix { inherit version toml-merge; };
      toml-merge = pkgs.callPackage ./nix/toml-merge.nix {};
    };
  };

  flake = rec {
    homeManagerModules.default = { pkgs, ... }: {
      imports =  [ ./nix/hm-module.nix ];

      nixpkgs = {
        overlays = [
          overlays.default
        ];
      };

      programs.helix.zhaith-configuration.package =
        withSystem pkgs.stdenv.hostPlatform.system ({ config, ... }: config.packages.default);
      };
      overlays.default = nil.overlays.default;
    };
  });
}

