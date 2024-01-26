{ config, pkgs, lib, ... }:

let
  inherit (lib) mkEnableOption mkIf types mkOption;
  cfg = config.programs.helix.zhaith-configuration;
in
{
  options.programs.helix.zhaith-configuration = {
    enable = mkEnableOption "Zhaith Izaliel's Helix configuration";

    defaultEditor = mkEnableOption null // {
      description = ''
        Whether to configure {command}`hx` as the default
        editor using the {env}`EDITOR` environment variable.
      '';
    };

    package = mkOption {
      type = types.package;
      defaultText = lib.literalMD "`packages.default` from the helix-config flake";
    };
  };

  config = mkIf cfg.enable {
    programs.helix = {
      inherit (cfg) enable defaultEditor;

      extraPackages = with pkgs; [
        taplo
      ];
    };

    home.file.".config/helix".source = "${cfg.package}";
  };
}

