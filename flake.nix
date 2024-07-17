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
      flake-parts-lib,
      config,
      ...
    }: let
      inherit (lib) types mkOption;
      inherit (flake-parts-lib) importApply;
      lib = nixpkgs.lib;
      flakeModules.helix = importApply ./helix {inherit withSystem;};
      flakeModules.zellij = importApply ./zellij {inherit withSystem;};
    in {
      imports = [
        flakeModules.helix
        flakeModules.zellij
      ];

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

        flake = {
          homeManagerModules.default = {...}: {
            imports = [
              config.homeManagerModules.helix-module
              config.homeManagerModules.zellij-module
            ];
          };
        };

        perSystem = {
          pkgs,
          system,
          ...
        }: {
          packages = {
            fusion = pkgs.callPackage ./common/fusion.nix {};
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
