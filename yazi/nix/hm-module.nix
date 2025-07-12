{package}: {
  config,
  lib,
  pkgs,
  ...
}: let
  inherit
    (lib)
    mkIf
    mkEnableOption
    mkOption
    mkPackageOption
    types
    literalExpression
    mapAttrs'
    nameValuePair
    recursiveUpdate
    optionalAttrs
    mapAttrsToList
    optionalString
    pathIsDirectory
    pathExists
    filter
    removeSuffix
    ;

  cfg = config.hellebore.dev-env.yazi;
  tomlFormat = pkgs.formats.toml {};

  generateToml = fileName: attrset:
    if attrset == {}
    then ""
    else "${tomlFormat.generate "${fileName}.toml" attrset}";

  zellijSettings = optionalAttrs config.hellebore.dev-env.zellij.enable (builtins.fromTOML (builtins.readFile ./zellij-yazi.toml));

  finalExtraPackages = cfg.extraPackages ++ (import ./dependencies.nix {inherit pkgs;});

  finalConfigPackage = package.override {
    extraConfig = {
      theme = generateToml "extra-yazi-theme" cfg.theme;
      keymap = generateToml "extra-yazi-keymap" cfg.keymap;
      settings = generateToml "extra-yazi-settings" (recursiveUpdate cfg.settings zellijSettings);
      flavors =
        mapAttrs'
        (name: value: nameValuePair "${name}.yazi" "${value}")
        cfg.flavors;
      plugins =
        mapAttrs'
        (name: value: nameValuePair "${name}.yazi" "${value}")
        cfg.plugins;
      initLua =
        if cfg.initLua == null
        then ""
        else if builtins.isPath cfg.initLua
        then cfg.initLua
        else let
          file = pkgs.writeTextFile {
            name = "yazi-init.lua";
            text = cfg.initLua;
          };
        in "${file}";
      highlight =
        if cfg.highlight == null
        then ""
        else if builtins.isPath cfg.highlight
        then cfg.highlight
        else let
          file = pkgs.writeTextFile {
            name = "yazi-highlight.tmTheme";
            text = cfg.highlight;
          };
        in "${file}";
    };
  };

  finalYaziPackage = pkgs.symlinkJoin {
    name = "${lib.getName cfg.packages.yazi}-wrapped-${lib.getVersion cfg.packages.yazi}";
    paths = [cfg.packages.yazi];
    preferLocalBuild = true;
    nativeBuildInputs = [pkgs.makeWrapper];
    postBuild = ''
      wrapProgram $out/bin/yazi \
        --suffix PATH : ${lib.makeBinPath finalExtraPackages}
    '';
  };
in {
  options.hellebore.dev-env.yazi = {
    enable = mkEnableOption "Hellebore's Dev-Env Yazi configuration";

    packages = {
      config = mkOption {
        default = finalConfigPackage;
        type = types.package;
        description = "Defines the package used to get Yazi's configuration from.";
      };

      yazi = mkPackageOption pkgs "yazi" {};
    };

    extraPackages = mkOption {
      default = [];
      type = types.listOf types.package;
      description = "Defines the list of additional runtimes to add to Yazi.";
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
          mgr.keymap = [
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
          mgr = {
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

    highlight = mkOption {
      type = with types; nullOr (either path lines);
      default = null;
      description = ''
        The highlight.tmTheme for your Yazi theme.

        This will **completely override** the default highlight.tmTheme bundled in the configuration.
      '';
      example = literalExpression "./init.lua";
    };

    plugins = mkOption {
      type = types.attrsOf (types.oneOf [types.path types.package]);
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
      type = types.attrsOf (types.oneOf [types.path types.package]);
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
    assertions = let
      mkAsserts = opt: requiredFiles:
        mapAttrsToList (name: value: let
          isDir = pathIsDirectory "${value}";
          msgNotDir =
            optionalString (!isDir)
            "The path or package should be a directory, not a single file.";
          isFileMissing = file:
            !(pathExists "${value}/${file}")
            || pathIsDirectory "${value}/${file}";
          missingFiles = filter isFileMissing requiredFiles;
          msgFilesMissing =
            optionalString (missingFiles != [])
            "The ${singularOpt} is missing these files: ${
              toString missingFiles
            }";
          singularOpt = removeSuffix "s" opt;
        in {
          assertion = isDir && missingFiles == [];
          message = ''
            Value at `programs.yazi.${opt}.${name}` is not a valid yazi ${singularOpt}.
            ${msgNotDir}
            ${msgFilesMissing}
            Evaluated value: `${value}`
          '';
        })
        cfg.${opt};
    in
      (mkAsserts "flavors" [
        "flavor.toml"
        "tmtheme.xml"
        "README.md"
        "preview.png"
        "LICENSE"
        "LICENSE-tmtheme"
      ])
      ++ (mkAsserts "plugins" ["init.lua"]);

    programs.yazi = {
      inherit (cfg) shellWrapperName;
      enable = true;

      package = finalYaziPackage;
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
