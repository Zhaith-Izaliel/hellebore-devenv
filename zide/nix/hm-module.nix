{
  zidePackage,
  package,
}: {
  config,
  lib,
  ...
}: let
  inherit
    (lib)
    mkIf
    mkEnableOption
    mkOption
    types
    ;

  utils = import ../../common/utils.nix {inherit lib;};
  extraTypes = import ../../common/types.nix {inherit lib;};

  cfg = config.hellebore.dev-env.zide;
  finalConfigPackage = package.override {
    extraLayouts = cfg.settings.layouts;
  };
in {
  options.hellebore.dev-env.zide = {
    enable = mkEnableOption "Hellebore's Dev-Env Zide configuration";

    packages = {
      config = mkOption {
        default = finalConfigPackage;
        type = types.package;
        description = "Defines the package used to get Yazi's configuration from.";
      };

      zide = mkOption {
        default = zidePackage;
        type = types.package;
        description = "Defines the package used to get Yazi's configuration from.";
      };
    };

    settings = {
      layouts = mkOption {
        type = types.attrsOf extraTypes.layoutsType;
        default = {};
        description = ''
          Each layout is written to {file}`$XDG_CONFIG_HOME/zide/layouts`.
          Where the name of every layouts is the layout name.

          The layouts name should not conflict with the layouts defined in Hellebore Dev-Env.

          See <https://zellij.dev/documentation/layouts> for the full list of options.
        '';
      };
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      (utils.mkConflictLayoutsAssertion [../layouts "${cfg.packages.zide}/layouts"] cfg.layouts "Zide")
    ];

    home.packages = [
      cfg.packages.config
    ];
  };
}
