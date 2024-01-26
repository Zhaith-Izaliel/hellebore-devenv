{ overlays }:
{ config, pkgs, lib, ... }:

let
  inherit (lib) mkEnableOption mkIf;
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
  };

  config = mkIf cfg.enable {
    nixpkgs = {
      inherit overlays;
    };

    programs.helix = {
      inherit (cfg) enable defaultEditor;

    };
  };
}

