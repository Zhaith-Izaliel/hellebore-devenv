{
  description = "Zhaith Izaliel's Helix configuration.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = inputs@{ flake-parts, helix, self, ... }:
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

    packages.default = pkgs.callPackage ./nix { inherit version; };
  };

  flake = {
    homeManagerModules.default = { pkgs, ... }: {
      imports =  [ ./nix/hm-module.nix ];

      programs.helix.zhaith-configuration.package =
        withSystem pkgs.stdenv.hostPlatform.system ({ config, ... }: config.packages.default);
      };
      overlays.default = helix.overlays.default;
    };
  });
}

