{
  stdenv,
  lib,
  version ? "git",
  extraConfig ? {
    layouts = [];
    config = "";
    themes = "";
    plugins = "";
  },
}: let
  inherit (lib) concatStringsSep optionalString;
  extraLayoutsInstall = concatStringsSep "\n" (builtins.map (item: "cp ${item.generatedFile} $out/layouts/${item.fileName}") extraConfig.layouts);
in
  stdenv.mkDerivation {
    inherit version;

    pname = "zellij-hellebore-dev-env";

    src = lib.cleanSource ../.;

    installPhase = concatStringsSep "\n" [
      ''
        runHook preInstall
        mkdir -p $out

        cp -r *.kdl $out

        mkdir -p $out/layouts
        cp -r layouts/*.kdl $out/layouts
      ''
      (
        optionalString ((builtins.length extraConfig.layouts) > 0)
        extraLayoutsInstall
      )
      ''
        runHook postInstall
      ''
    ];
  }
