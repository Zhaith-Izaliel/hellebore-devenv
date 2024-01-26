{ config, pkgs, lib, stdenv, ... }:

let
  inherit (lib) mkEnableOption mkIf types mkOption;
  cfg = config.programs.helix.zhaith-configuration;
  extraPackages = (import ./dependencies.nix { inherit pkgs stdenv; }).packages;
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
      inherit extraPackages;
    };

    home.file.".config/helix".source = "${cfg.package}";
  };
}

