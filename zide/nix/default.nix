{
  stdenv,
  lib,
  version ? "git",
  zide,
  extraLayouts ? {},
}: let
  inherit (lib) concatStringsSep optionalString;
  extraLayoutsInstall = concatStringsSep "\n" (builtins.map (item: "cp ${item.generatedFile} $out/layouts/${item.fileName}") extraLayouts);
in
  stdenv.mkDerivation {
    inherit version;
    src = lib.cleanSource ../.;

    pname = "zide-hellebore-dev-env";

    buildInputs = [
      zide
    ];

    installPhase = concatStringsSep "\n" [
      ''
        runHook preInstall
        mkdir -p $out
        mkdir -p $out/layouts
        cp -r layouts/* $out/layouts
        cp -r ${zide}/* $out
      ''
      (
        optionalString ((builtins.length extraLayouts) > 0)
        extraLayoutsInstall
      )
      ''
        runHook postInstall
      ''
    ];
  }
