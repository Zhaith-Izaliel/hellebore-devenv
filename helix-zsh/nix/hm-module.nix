{
  package,
  helix-driver-package,
}: {
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf mkEnableOption mkOption types;
  cfg = config.hellebore.dev-env.helix-zsh;
in {
  options.hellebore.dev-env.helix-zsh = {
    enable = mkEnableOption "Helix-Zsh plugin for ZSH";

    packages = {
      helix-zsh = mkOption {
        type = types.package;
        default = package;
        description = "Defines the package for helix-zsh.";
      };
      helix-driver = mkOption {
        type = types.package;
        default = helix-driver-package;
        description = "Defines the package for helix-driver.";
      };
    };
  };

  config = mkIf cfg.enable {
    home.packages = [
      cfg.packages.helix-driver
    ];

    programs.zsh = {
      plugins = [
        {
          name = "helix-zsh";
          src = cfg.packages.helix-zsh;
          file = "share/helix-zsh/helix-zsh.plugin.zsh";
        }
      ];
    };
  };
}
