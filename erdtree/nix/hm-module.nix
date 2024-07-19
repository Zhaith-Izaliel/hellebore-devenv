{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkPackageOption mkEnableOption mkOption types;
  cfg = config.hellebore.dev-env.erdtree;
in {
  options.hellebore.dev-env.erdtree = {
    enable = mkEnableOption "Erdtree - A modern, cross-platform, multi-threaded,
    and general purpose filesystem and disk-usage utility that is aware of
    .gitignore and hidden file rules";

    package = mkPackageOption pkgs "erdtree" {};

    settings = mkOption {
      type = types.lines;
      default = "";
      example = ''
        --human
        --layout inverted
      '';
      description = "Override Hellebore's Dev-Env Erdtree configuration options.";
    };
  };

  config = mkIf cfg.enable {
    home.packages = [cfg.package];
    xdg.configHome."erdtree/.erdtreerc" =
      if cfg.settings != ""
      then {
        text = cfg.settings;
      }
      else {
        source = ../erdtreerc;
      };
  };
}
