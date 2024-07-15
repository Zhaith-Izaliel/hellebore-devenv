localFlake: {
  inputs,
  config,
  lib,
  self,
  ...
}: {
  perSystem = {
    pkgs,
    system,
    ...
  }: {
    packages = rec {
      default = pkgs.callPackage ./nix {
        inherit fusion;
        version = config.flake.version;
      };
      helix = inputs.helix.packages.${system}.default;
      fusion = pkgs.callPackage ./nix/dependencies/fusion.nix {};
    };
  };

  flake = rec {
    homeManagerModules.default = {pkgs, ...}: let
      home-module = import ./nix/hm-module.nix {
        package = localFlake.withSystem pkgs.stdenv.hostPlatform.system ({config, ...}: config.packages.default);
        helixPackage = localFlake.withSystem pkgs.stdenv.hostPlatform.system ({config, ...}: config.packages.helix);
        overlays = overlays.default;
      };
    in {
      imports = [home-module];
    };

    overlays.default = [
      inputs.nil.overlays.default
      (final: prev: {
        simple-completion-language-server = inputs.simple-completion-language-server.defaultPackage.${final.stdenv.hostPlatform.system};
      })
    ];
  };
}
