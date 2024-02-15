{package}: {
  config,
  pkgs,
  lib,
  stdenv,
  ...
}: let
  inherit (lib) mkEnableOption mkIf types mkOption;
  inherit (dependencies) language-servers debug-adapters formatters;

  cfg = config.programs.helix.zhaith-configuration;
  extraLanguages = import ./extraLanguages.nix {inherit pkgs;};
  dependencies = import ./dependencies {inherit pkgs stdenv lib;};
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
  };

  config = mkIf cfg.enable {
    programs.helix = {
      inherit (cfg) enable defaultEditor;

      extraPackages = language-servers ++ debug-adapters ++ formatters;
    };

    home.file.".config/helix".source = "${cfg.package}";
  };
}
