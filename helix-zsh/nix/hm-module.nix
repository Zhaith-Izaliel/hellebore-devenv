{package}: {
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf mkEnableOption mkOption types;
  cfg = config.hellebore.dev-env.helix-zsh;
in {
  options.hellebore.dev-env.helix-zsh = {
    enable = mkEnableOption "Helix-Zsh plugin for ZSH";

    package = mkOption {
      type = types.package;
      default = package;
      description = "Defines the package for helix-zsh.";
    };
  };

  config = mkIf cfg.enable {
    programs.zsh = {
      plugins = [
        {
          name = "helix-zsh";
          src = cfg.package;
          file = "share/helix-zsh/helix-zsh.plugin.zsh";
        }
      ];
    };
  };
}
