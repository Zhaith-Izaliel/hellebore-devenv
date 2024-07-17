{package}: {
  config,
  pkgs,
  lib,
  stdenv,
  ...
}: let
  inherit
    (lib)
    mkEnableOption
    mkIf
    types
    mkOption
    mkPackageOption
    literalExpression
    mapAttrsToList
    optionalString
    pipe
    filterAttrs
    intersectLists
    concatStringsSep
    ;
  toKdl = lib.hm.generators.toKdl {};

  cfg = config.hellebore.dev-env.zellij;

  writeKdlFile = name: content:
    pkgs.writeTextFile {
      inherit name;
    }
    // (
      if builtins.isPath content
      then {
        source = content;
      }
      else {
        text = toKdl content;
      }
    );

  toLayoutFileName = name: value: "${value.name}${optionalString value.isSwap ".swap"}.kdl";

  finalPackage = cfg.package.override {
    extraConfig = {
      config = writeKdlFile "zellij-generated-config.kdl" cfg.settings.config;
      layouts =
        mapAttrsToList (
          name: value: let
            fileName = toLayoutFileName name value;
            content = value.config;
          in "${writeKdlFile fileName content}"
        )
        cfg.settings.layouts;
    };
  };

  kdlType = with types; let
    primitive = nullOr (oneOf [
      bool
      int
      float
      str
      path
      (attrsOf primitive)
      (listOf primitive)
    ]);
    valueType = attrsOf primitive;
  in
    nullOr (oneOf [
      path
      valueType
    ]);

  layoutsType = types.submodule {
    name = mkOption {
      type = types.nonEmptyStr;
      default = "";
      description = "The name of the layout";
    };

    isSwap = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Defines if the layout is a swap layout.

        See <https://zellij.dev/documentation/swap-layouts> for the full list of options.
      '';
    };

    config = mkOption {
      type = kdlType;
      default = null;
      description = ''
        The configuration of the layout.

        See <https://zellij.dev/documentation/layouts> for the full list of options.
      '';

      example = literalExpression ''
        {
          layout = {
            tab_template = {
              _props = {
                name = "ui";
              };


            }
          };
        }
      '';
    };
  };
in {
  options.hellebore.dev-env.zellij = {
    enable = mkEnableOption "Hellebore Dev-Env's Zellij configuration";

    defaultEditor =
      mkEnableOption null
      // {
        description = ''
          Whether to configure {command}`hx` as the default
          editor using the {env}`EDITOR` environment variable.
        '';
      };

    packages = {
      config = mkOption {
        default = package;
        type = types.package;
        description = "Defines the package used to get Helix's configuration from.";
      };

      zellij = mkPackageOption pkgs "zellij" {};
    };

    shellIntegrations = {
      zsh =
        mkEnableOption "Zsh integration"
        // {
          default = false;
        };
      bash =
        mkEnableOption "Bash integration"
        // {
          default = false;
        };
      fish =
        mkEnableOption "Fish integration"
        // {
          default = false;
        };
    };

    settings = {
      config = mkOption {
        type = kdlType;
        default = {};
        description = ''
          Configuration written to
          {file}`$XDG_CONFIG_HOME/zellij/config.kdl`.

          See <https://zellij.dev/documentation> for the full list of options.
        '';
        example = literalExpression ''
          {
            keybinds = {
              _props = { # This attribute defines KDL props.
                clear-defaults = true;
              };

              resize = {
                "bind \"Ctrl n\"" = { # Use a string for nodes with the same name but with different arguments, since Nix doesn't allow multiple attributes with the same names on the same level.
                  SwitchMode = {
                    _args = [ "Normal" ]; # This attribute defines multiple KDL args;
                  }
                };
              };
            };
          }
        '';
      };

      layouts = mkOption {
        type = types.attrsOf layoutsType;
        default = {};
        description = ''
          Each theme is written to
          {file}`$XDG_CONFIG_HOME/zellij/layouts`.
          Where the name of every layouts is the layout name (in the example "example-layout").

          The layouts name should not conflict with the layouts defined in Hellebore Dev-Env.

          See <https://zellij.dev/documentation/layouts> for the full list of options.
        '';
      };
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      (let
        conflictLayouts = intersectLists defaultLayouts definedLayouts;
        prettyPrintConflicts = concatStringsSep "\n" (builtins.map (item: "- ${item}") conflictLayouts);
        defaultLayouts = pipe ../layouts [
          builtins.readDir
          (filterAttrs (name: value: value == "regular"))
          (mapAttrsToList (name: value: name))
        ];
        definedLayouts = mapAttrsToList (name: value: toLayoutFileName name value) cfg.settings.layouts;
      in {
        assertion = (builtins.length conflictLayouts) > 0;
        message =
          ''
            These layouts names conflict with the one defined in Hellebore's Dev-Env:
          ''
          + prettyPrintConflicts;
      })
    ];

    programs.zellij = {
      enable = true;
      package = cfg.packages.zellij;
      enableZshIntegration = cfg.shellIntegrations.zsh;
      enableBashIntegration = cfg.shellIntegrations.bash;
      enableFishIntegration = cfg.shellIntegrations.fish;
    };

    xdg.configFile = {
      "zellij".source = "${finalPackage}";
    };
  };
}
