{
  package,
  helixPackage,
  overlays,
}: {
  config,
  pkgs,
  lib,
  stdenv,
  ...
}: let
  inherit (lib) mkEnableOption mkIf types mkOption mapAttrsToList flatten recursiveUpdate literalExpression warn concatStringsSep;
  tomlFormat = pkgs.formats.toml {};

  cfg = config.programs.helix.zhaith-configuration;
  extraLanguages = import ./extraLanguages.nix {inherit pkgs lib;};
  extraPackages = flatten (
    mapAttrsToList
    (name: value: value)
    (import ./dependencies {inherit pkgs stdenv lib;})
  );

  finalPackage = cfg.package.override {
    extraConfig = {
      languages = tomlFormat.generate "zhaith-helix-extraLanguages" (recursiveUpdate extraLanguages cfg.settings.languages);
      config = tomlFormat.generate "zhaith-helix-extraConfig" cfg.settings.config;
      themes = builtins.mapAttrs (name: value: tomlFormat.generate name "zhaith-helix-theme-${value}") cfg.settings.themes;
      ignores = concatStringsSep "\n" cfg.settings.ignores;
    };
  };
  finalExtraPackages = cfg.extraPackages ++ extraPackages;
in {
  options.programs.helix.zhaith-configuration = {
    enable = mkEnableOption "Zhaith Izaliel's Helix configuration";

    defaultEditor =
      mkEnableOption null
      // {
        description = ''
          Whether to configure {command}`hx` as the default
          editor using the {env}`EDITOR` environment variable.
        '';
      };

    package = mkOption {
      default = package;
      type = types.package;
      description = "Defines the package used to get Helix's configuration from.";
    };

    helixPackage = mkOption {
      default = helixPackage;
      type = types.package;
      description = "Defines the Helix package to use.";
    };

    extraPackages = mkOption {
      default = [];
      type = types.listOf types.package;
      description = "Defines the list of additional runtimes to add to Helix. Usually language servers.";
    };

    settings = {
      ignores = mkOption {
        type = types.listOf types.str;
        default = [];
        example = [".build/" "!.gitignore"];
        description = ''
          List of paths that should be globally ignored for file picker.
          Supports the usual ignore and negative ignore (unignore) rules used in `.gitignore` files.

          This takes precedence on the default ignores provided by this module.
        '';
      };

      languages = mkOption {
        type = with types;
          coercedTo (listOf tomlFormat.type) (language:
            warn ''
              The syntax of programs.helix.languages has changed.
              It now generates the whole languages.toml file instead of just the language array in that file.

              Use
              programs.helix.languages = { language = <languages list>; }
              instead.
            '' {inherit language;}) (addCheck tomlFormat.type builtins.isAttrs);
        default = {};
        example = literalExpression ''
          {
            # the language-server option currently requires helix from the master branch at https://github.com/helix-editor/helix/
            language-server.typescript-language-server = with pkgs.nodePackages; {
              command = "''${typescript-language-server}/bin/typescript-language-server";
              args = [ "--stdio" "--tsserver-path=''${typescript}/lib/node_modules/typescript/lib" ];
            };

            language = [{
              name = "rust";
              auto-format = false;
            }];
          }
        '';
        description = ''
          Extra Language specific configuration at
          {file}`$XDG_CONFIG_HOME/helix/languages.toml`.

          This takes precedence on the default language configuration provided by this module.

          See <https://docs.helix-editor.com/languages.html>
          for more information.
        '';
      };

      config = mkOption {
        type = tomlFormat.type;
        default = {};
        example = literalExpression ''
          {
            theme = "base16";
            editor = {
              line-number = "relative";
              lsp.display-messages = true;
            };
            keys.normal = {
              space.space = "file_picker";
              space.w = ":w";
              space.q = ":q";
              esc = [ "collapse_selection" "keep_primary_selection" ];
            };
          }
        '';
        description = ''
          Extra Configuration written to
          {file}`$XDG_CONFIG_HOME/helix/config.toml`.

          This takes precedence on the default configuration provided by this module.

          See <https://docs.helix-editor.com/configuration.html>
          for the full list of options.
        '';
      };

      themes = mkOption {
        type = types.attrsOf tomlFormat.type;
        default = {};
        example = literalExpression ''
          {
            base16 = let
              transparent = "none";
              gray = "#665c54";
              dark-gray = "#3c3836";
              white = "#fbf1c7";
              black = "#282828";
              red = "#fb4934";
              green = "#b8bb26";
              yellow = "#fabd2f";
              orange = "#fe8019";
              blue = "#83a598";
              magenta = "#d3869b";
              cyan = "#8ec07c";
            in {
              "ui.menu" = transparent;
              "ui.menu.selected" = { modifiers = [ "reversed" ]; };
              "ui.linenr" = { fg = gray; bg = dark-gray; };
              "ui.popup" = { modifiers = [ "reversed" ]; };
              "ui.linenr.selected" = { fg = white; bg = black; modifiers = [ "bold" ]; };
              "ui.selection" = { fg = black; bg = blue; };
              "ui.selection.primary" = { modifiers = [ "reversed" ]; };
              "comment" = { fg = gray; };
              "ui.statusline" = { fg = white; bg = dark-gray; };
              "ui.statusline.inactive" = { fg = dark-gray; bg = white; };
              "ui.help" = { fg = dark-gray; bg = white; };
              "ui.cursor" = { modifiers = [ "reversed" ]; };
              "variable" = red;
              "variable.builtin" = orange;
              "constant.numeric" = orange;
              "constant" = orange;
              "attributes" = yellow;
              "type" = yellow;
              "ui.cursor.match" = { fg = yellow; modifiers = [ "underlined" ]; };
              "string" = green;
              "variable.other.member" = red;
              "constant.character.escape" = cyan;
              "function" = blue;
              "constructor" = blue;
              "special" = blue;
              "keyword" = magenta;
              "label" = magenta;
              "namespace" = blue;
              "diff.plus" = green;
              "diff.delta" = yellow;
              "diff.minus" = red;
              "diagnostic" = { modifiers = [ "underlined" ]; };
              "ui.gutter" = { bg = black; };
              "info" = blue;
              "hint" = dark-gray;
              "debug" = dark-gray;
              "warning" = yellow;
              "error" = red;
            };
          }
        '';
        description = ''
          Each theme is written to
          {file}`$XDG_CONFIG_HOME/helix/themes/theme-name.toml`.
          Where the name of each attribute is the theme-name (in the example "base16").

          See <https://docs.helix-editor.com/themes.html>
          for the full list of options.
        '';
      };
    };
  };

  config = mkIf cfg.enable {
    nixpkgs.overlays = overlays;

    programs.helix = {
      inherit (cfg) enable defaultEditor;
      package = cfg.helixPackage;
      extraPackages = finalExtraPackages;
    };

    home.file.".config/helix".source = "${finalPackage}";
  };
}
