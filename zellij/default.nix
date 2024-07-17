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
      zellij-config = pkgs.callPackage ./nix {
        version = config.flake.version;
      };
    };
  };

  flake = {
    homeManagerModules.default = {pkgs, ...}: let
      home-module = import ./nix/hm-module.nix {
        package = localFlake.withSystem pkgs.stdenv.hostPlatform.system ({config, ...}: config.packages.zellij-config);
      };
    in {
      imports = [home-module];
    };
  };
}
