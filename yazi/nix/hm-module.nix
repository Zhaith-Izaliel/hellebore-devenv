{package}: {
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkEnableOption mkOption mkPackageOption types literalExpression mapAttrs' nameValuePair recursiveUpdate optionalAttrs;
  cfg = config.hellebore.dev-env.yazi;
  tomlFormat = pkgs.formats.toml {};

  generateToml = fileName: attrset:
    if attrset == {}
    then ""
    else tomlFormat.generate fileName attrset;

  zellijSettings = optionalAttrs config.hellebore.dev-env.zellij.enable (builtins.fromTOML (builtins.readFile ./zellij-yazi.toml));

  finalPackage = package.override {
    installSideBar = config.hellebore.dev-env.zellij.enableSidebar;
    extraConfig = {
      theme = generateToml "extra-yazi-theme" cfg.theme;
      keymap = generateToml "extra-yazi-keymap" cfg.keymap;
      settings = generateToml "extra-yazi-settings" (recursiveUpdate cfg.settings zellijSettings);
      flavors = mapAttrs' (name: value:
        nameValuePair "${name}.yazi" value)
      cfg.flavors;
      plugins = mapAttrs' (name: value:
        nameValuePair "${name}.yazi" value)
      cfg.plugins;
      initLua =
        if builtins.isPath cfg.initLua
        then cfg.initLua
        else let
          file = pkgs.writeTextFile {
            name = "yazi-init.lua";
            text = cfg.initLua;
          };
        in "${file}";
    };
  };
in {
  options.hellebore.dev-env.yazi = {
    enable = mkEnableOption "Hellebore's Dev-Env Yazi configuration";

    packages = {
      config = mkOption {
        default = finalPackage;
        type = types.package;
        description = "Defines the package used to get Helix's configuration from.";
      };

      yazi = mkPackageOption pkgs "yazi" {};
    };

    shellWrapperName = mkOption {
      type = types.str;
      default = "yy";
      example = "y";
      description = ''
        Name of the shell wrapper to be called.
      '';
    };

    keymap = mkOption {
      type = tomlFormat.type;
      default = {};
      example = literalExpression ''
        {
          input.keymap = [
            { exec = "close"; on = [ "<C-q>" ]; }
            { exec = "close --submit"; on = [ "<Enter>" ]; }
            { exec = "escape"; on = [ "<Esc>" ]; }
            { exec = "backspace"; on = [ "<Backspace>" ]; }
          ];
          manager.keymap = [
            { exec = "escape"; on = [ "<Esc>" ]; }
            { exec = "quit"; on = [ "q" ]; }
            { exec = "close"; on = [ "<C-q>" ]; }
          ];
        }
      '';
      description = ''
        Configuration written to
        {file}`$XDG_CONFIG_HOME/yazi/keymap.toml`.

        See <https://yazi-rs.github.io/docs/configuration/keymap>
        for the full list of options.
      '';
    };

    settings = mkOption {
      type = tomlFormat.type;
      default = {};
      example = literalExpression ''
        {
          log = {
            enabled = false;
          };
          manager = {
            show_hidden = false;
            sort_by = "modified";
            sort_dir_first = true;
            sort_reverse = true;
          };
        }
      '';
      description = ''
        Configuration written to
        {file}`$XDG_CONFIG_HOME/yazi/yazi.toml`.

        See <https://yazi-rs.github.io/docs/configuration/yazi>
        for the full list of options.
      '';
    };

    theme = mkOption {
      type = tomlFormat.type;
      default = {};
      example = literalExpression ''
        {
          filetype = {
            rules = [
              { fg = "#7AD9E5"; mime = "image/*"; }
              { fg = "#F3D398"; mime = "video/*"; }
              { fg = "#F3D398"; mime = "audio/*"; }
              { fg = "#CD9EFC"; mime = "application/x-bzip"; }
            ];
          };
        }
      '';
      description = ''
        Configuration written to
        {file}`$XDG_CONFIG_HOME/yazi/theme.toml`.

        See <https://yazi-rs.github.io/docs/configuration/theme>
        for the full list of options
      '';
    };

    initLua = mkOption {
      type = with types; nullOr (either path lines);
      default = null;
      description = ''
        The init.lua for Yazi itself.

        This will **completely override** the default init.lua bundled in the configuration.
      '';
      example = literalExpression "./init.lua";
    };

    plugins = mkOption {
      type = with types; attrsOf (oneOf [path package]);
      default = {};
      description = ''
        Lua plugins.
        Values should be a package or path containing an `init.lua` file.
        Will be linked to {file}`$XDG_CONFIG_HOME/yazi/plugins/<name>.yazi`.

        See <https://yazi-rs.github.io/docs/plugins/overview>
        for documentation.
      '';
      example = literalExpression ''
        {
          foo = ./foo;
          bar = pkgs.bar;
        }
      '';
    };

    flavors = mkOption {
      type = with types; attrsOf (oneOf [path package]);
      default = {};
      description = ''
        Pre-made themes.
        Values should be a package or path containing the required files.
        Will be linked to {file}`$XDG_CONFIG_HOME/yazi/flavors/<name>.yazi`.

        See <https://yazi-rs.github.io/docs/flavors/overview/> for documentation.
      '';
      example = literalExpression ''
        {
          foo = ./foo;
          bar = pkgs.bar;
        }
      '';
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
      nushell =
        mkEnableOption "Nu shell integration"
        // {
          default = config.programs.nushell.enable;
        };
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      unar
      mpv
      xdg-utils
    ];

    programs.yazi = {
      inherit (cfg) shellWrapperName;
      enable = true;

      package = cfg.packages.yazi;

      enableZshIntegration = cfg.shellIntegrations.zsh;
      enableBashIntegration = cfg.shellIntegrations.bash;
      enableFishIntegration = cfg.shellIntegrations.fish;
      enableNushellIntegration = cfg.shellIntegrations.nushell;
    };

    xdg.configFile = {
      "yazi".source = cfg.packages.config;
    };
  };
}
