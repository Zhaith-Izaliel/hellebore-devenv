localFlake: {
  inputs,
  config,
  ...
}: {
  perSystem = {
    pkgs,
    system,
    ...
  }: {
    packages = {
      helix-config = pkgs.callPackage ./nix {
        fusion = localFlake.withSystem pkgs.stdenv.hostPlatform.system ({config, ...}: config.packages.fusion);
        version = config.flake.version;
      };
      helix = inputs.helix.packages.${system}.default;
    };
  };

  flake = rec {
    homeManagerModules.default = {pkgs, ...}: let
      home-module = import ./nix/hm-module.nix {
        package = localFlake.withSystem pkgs.stdenv.hostPlatform.system ({config, ...}: config.packages.helix-config);
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
