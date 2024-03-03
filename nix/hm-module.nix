{package, helixPackage}: {
  config,
  pkgs,
  lib,
  stdenv,
  ...
}: let
  inherit (lib) mkEnableOption mkIf types mkOption mapAttrsToList flatten;

  cfg = config.programs.helix.zhaith-configuration;
  extraLanguages = import ./extraLanguages.nix {inherit pkgs;};
  dependencies = import ./dependencies {inherit pkgs stdenv lib;};
  extraPackages = flatten (mapAttrsToList (name: value: value) dependencies)); 
in {
  options.programs.helix.zhaith-configuration = {
    enable = mkEnableOption "Zhaith Izaliel's Helix configuration";

    defaultEditor =
      mkEnableOption null
      // {
        description = ''
          Whether to configure {command}`hx` as the default
          editor using the {env}`EDITOR` environment variable.
        '';
      };

    package = mkOption {
      default = package.override {
        inherit extraLanguages;
      };
      type = types.package;
      description = "Defines the package used to get Helix's configuration from.";
    };

    helixPackage = mkOption {
      default = helixPackage;
      type = types.package;
      description = "Defines the Helix package to use.";
    };
  };

  config = mkIf cfg.enable {
    programs.helix = {
      inherit extraPackages;
      inherit (cfg) enable defaultEditor;
      package = cfg.helixPackage;
    };

    home.file.".config/helix".source = "${cfg.package}";
  };
}
