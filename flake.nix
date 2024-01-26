{
  description = "Zhaith Izaliel's Helix configuration.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    helix = {
      url = "github:helix-editor/helix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs: with inputs;
  let
    version = "1.0.0";
  in
  with import nixpkgs { inherit system; };
  flake-utils.lib.eachDefaultSystem (system:
    rec {
      workspaceShell = pkgs.mkShell {
        # nativeBuildInputs is usually what you want -- tools you need to run
        nativeBuildInputs = with pkgs; [
          taplo
          toml2nix
        ];
      };

      devShells = {
        # nix develop
        "${system}".default = workspaceShell;
        default = workspaceShell;
      };
      packages.default = pkgs.callPackage ./nix { inherit version; };
    }
    ) // {
      homeManagerModules.default = import ./nix {
        overlays = [
          overlays.default
        ];
        configPackage = self.packages.${pkgs.system}.default;
      };
      overlays.default = helix.overlays.default;
    };
}

