{
  lib,
  pkgs,
}: let
  inherit
    (lib)
    intersectLists
    concatStringsSep
    pipe
    filterAttrs
    mapAttrsToList
    optionalString
    concatMap
    zipAttrs
    ;

  toKdl = lib.hm.generators.toKdl {};
in rec {
  mkFinalLayouts = layouts:
    mapAttrsToList (
      name: value: let
        fileName = toLayoutFileName name value;
        content = value.content;
      in {
        inherit fileName;
        generatedFile = writeKdlFile fileName content;
      }
    )
    layouts;

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

  /*
  Return an assertion that checks if Zellij layouts added by the configuration (here `configLayouts`) conflicts with the ones defined locally in the package (here `layoutsPath`)

  ```nix
  assertions = [
    (mkConflictLayoutsAssertion ../layouts cfg.layouts "Zellij")
  ];
  ```

  # Inputs

    `layoutsPath`

    : The local path to the built-ins layouts

    `configLayouts`

    : The layouts defined in the configuration

    `program`

    : The name of the program associated with the conflicting layouts.

    # Type

    ```
    mkConflictLayoutsAssertion :: Path -> AttrSet -> String -> AttrSet
    ```
  */
  mkConflictLayoutsAssertion = layoutsPaths: configLayouts: program: let
    conflictLayouts = intersectLists defaultLayouts definedLayouts;
    prettyPrintConflicts = concatStringsSep "\n" (builtins.map (item: "- ${item}") conflictLayouts);
    defaultLayouts = pipe layoutsPaths [
      (concatMap builtins.readDir)
      zipAttrs
      (filterAttrs (name: value: value == "regular"))
      (mapAttrsToList (name: value: name))
    ];
    definedLayouts = mapAttrsToList (name: value: toLayoutFileName name value) configLayouts;
  in {
    assertion = (builtins.length conflictLayouts) == 0;
    message =
      "These ${program} layouts conflict with the ones defined in Hellebore's Dev-Env:\n"
      + prettyPrintConflicts;
  };
}
