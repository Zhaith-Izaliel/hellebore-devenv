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
        extraLanguages = ''
          [language-server.vuels.config.typescript]
          tsdk = "${pkgs.typescript}/lib/node_modules/typescript/lib/"
        '';
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

    home.file.".config/helix/config.toml".source = "${cfg.package}/config.toml";
    home.file.".config/helix/languages.toml".source = "${cfg.package}/languages.toml";
  };
}
