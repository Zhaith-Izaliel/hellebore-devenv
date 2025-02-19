{lib}: let
  inherit (lib) types mkOption literalExpression;
in rec {
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
}
