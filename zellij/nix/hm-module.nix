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

  writeKdlFile = name: content: let
    file = pkgs.writeTextFile {
      inherit name;
      text =
        if builtins.isPath content
        then builtins.readFile content
        else toKdl content;
    };
  in "${file}";

  toLayoutFileName = name: value: "${name}${optionalString value.isSwap ".swap"}.kdl";

  finalPluginsKdlAttrs = builtins.mapAttrs (name: value:
    {
      _props = {
        inherit (value) location;
      };
    }
    // value.settings)
  cfg.plugins;

  finalPackage = cfg.packages.config.override {
    extraConfig = {
      config = writeKdlFile "zellij-generated-config.kdl" cfg.settings;
      layouts =
        mapAttrsToList (
          name: value: let
            fileName = toLayoutFileName name value;
            content = value.content;
          in {
            inherit fileName;
            generatedFile = writeKdlFile fileName content;
          }
        )
        cfg.layouts;
      themes = writeKdlFile "zellij-generated-themes.kdl" {themes = cfg.themes;};
      plugins = writeKdlFile "zellij-generated-plugins-aliases.kdl" {plugins = finalPluginsKdlAttrs;};
    };
  };

  pathOrKdlType = with types;
    nullOr (oneOf [
      path
      kdlType
    ]);

  kdlType = with types; let
    valueType = nullOr (oneOf [
      bool
      int
      float
      str
      path
      (attrsOf valueType)
      (listOf valueType)
    ]);
  in
    valueType;

  layoutsType = types.submodule {
    options = {
      isSwap = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Defines if the layout is a swap layout.

          See <https://zellij.dev/documentation/swap-layouts> for the full list of options.
        '';
      };

      content = mkOption {
        type = pathOrKdlType;
        default = null;
        description = ''
          The configuration of the layout.
          Can be a path to a KDL file or an attribute set representing a KDL configuration.

          See <https://zellij.dev/documentation/layouts> for the full list of options.
        '';

        example = literalExpression ''
          {
            layout = {
              tab_template = {
                _props = {
                  name = "ui";
                };
                pane = {
                  _props = {
                    size = 1;
                    borderless = true;
                  };
                  plugin = {
                    _props = {
                     location = "zellij:tab-bar";
                    };
                  };
                };
                children = {};
              };
            };
          }
        '';
      };
    };
  };

  pluginsType = types.submodule {
    options = {
      location = mkOption {
        type = types.oneOf [types.nonEmptyStr types.path];
        default = "";
        description = ''
          Defines the plugin location. Can be a path to a wasm file or an URL

          See <https://zellij.dev/documentation/plugin-loading> for more information.
        '';
      };

      settings = mkOption {
        type = kdlType;
        default = {};
        description = ''
          The configuration of the plugin.

          See <https://zellij.dev/documentation/plugins> for the full list of options.
        '';
      };
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
        default = finalPackage;
        type = types.package;
        description = "Defines the package used to get Helix's configuration from.";
      };

      zellij = mkPackageOption pkgs "zellij" {};
    };

    shellIntegrations = {
      zsh =
        mkEnableOption "Zsh integration"
        // {
          default = config.programs.zsh.enable;
        };
      bash =
        mkEnableOption "Bash integration"
        // {
          default = config.programs.bash.enable;
        };
      fish =
        mkEnableOption "Fish integration"
        // {
          default = config.programs.fish.enable;
        };
    };

    autoAttach = mkEnableOption "Zellij's auto attach to an existing session on launch";

    autoExit = mkEnableOption "Zellij's auto exit shell when leaving a session";

    enableSidebar =
      mkEnableOption "Zellij's file manager sidebar using Yazi. Needs `hellebore.dev-env.yazi` to be enabled."
      // {
        default = config.hellebore.dev-env.yazi.enable;
      };

    settings = mkOption {
      type = pathOrKdlType;
      default = {};
      description = ''
        Configuration written to {file}`$XDG_CONFIG_HOME/zellij/config.kdl`.
        Can be a path to a KDL file or an attribute set representing a KDL configuration.

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
        Each layout is written to {file}`$XDG_CONFIG_HOME/zellij/layouts`.
        Where the name of every layouts is the layout name.

        The layouts name should not conflict with the layouts defined in Hellebore Dev-Env.

        See <https://zellij.dev/documentation/layouts> for the full list of options.
      '';
    };

    themes = mkOption {
      type = types.attrsOf kdlType;
      default = {};
      description = ''
        Each theme is written to {file}`$XDG_CONFIG_HOME/zellij/config.kdl`.
        Where the name of every theme is the theme name (in the example "dracula").

        See <https://zellij.dev/documentation/themes> for the full list of options.
      '';
      example = literalExpression ''
        {
          dracula {
            fg = { _args = [ 248 248 242 ]; };
            bg = { _args = [ 40 42 54 ]; };
            red = { _args = [ 255 85 85 ]; };
            green = { _args = [ 80 250 123 ]; };
            yellow = { _args = [ 241 250 140 ]; };
            blue = { _args = [ 98 114 164 ]; };
            magenta = { _args = [ 255 121 198 ]; };
            orange = { _args = [ 255 184 108 ]; };
            cyan = { _args = [ 139 233 253 ]; };
            black = { _args = [ 0 0 0 ]; };
            white = { _args = [ 255 255 255 ]; };
          }
        }
      '';
    };

    plugins = mkOption {
      type = types.attrsOf pluginsType;
      default = {};
      description = ''
        Each plugin is written to {file}`$XDG_CONFIG_HOME/zellij/config.kdl`.
        Where the name of every plugins is the plugin alias.

        See <https://zellij.dev/documentation/plugin-aliases> for more information.
      '';
    };

    layoutAlias = mkEnableOption "`zlayout` as an alias to select a layout under {file}`$XDG_CONFIG_HOME/zellij/layouts` in a new tab.";
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
        definedLayouts = mapAttrsToList (name: value: toLayoutFileName name value) cfg.layouts;
      in {
        assertion = (builtins.length conflictLayouts) == 0;
        message =
          "These Zellij layouts conflict with the ones defined in Hellebore's Dev-Env:\n"
          + prettyPrintConflicts;
      })
      {
        assertion = cfg.enableSidebar -> config.hellebore.dev-env.yazi.enable;
        message = "You must enable Yazi through `config.hellebore.dev-env.yazi.enable` to use the sidebar in Zellij.";
      }
    ];

    home.shellAliases = mkIf cfg.layoutAlias {
      zlayout = "zellij action new-tab --layout";
    };

    home.sessionVariables = {
      ZELLIJ_AUTO_ATTACH =
        if cfg.autoAttach
        then "true"
        else "false";
      ZELLIJ_AUTO_EXIT =
        if cfg.autoExit
        then "true"
        else "false";
    };

    programs.zellij = {
      enable = true;
      package = cfg.packages.zellij;
      enableZshIntegration = cfg.shellIntegrations.zsh;
      enableBashIntegration = cfg.shellIntegrations.bash;
      enableFishIntegration = cfg.shellIntegrations.fish;
    };

    xdg.configFile = {
      "zellij".source = cfg.packages.config;
    };
  };
}
