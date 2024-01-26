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
  flake-utils.lib.eachDefaultSystem (system:
    with import nixpkgs { inherit system; };
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
    }
    ) // rec {
      homeManagerModules.default = import ./nix {
        overlays = [
          overlays.default
        ];
      };
      overlays.default = helix.overlays.default;
    };
}

