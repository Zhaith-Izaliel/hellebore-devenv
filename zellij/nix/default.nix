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

    pname = "helix-zhaith-configuration";

    src = lib.cleanSource ../.;

    installPhase = concatStringsSep "\n" [
      ''
        runHook preInstall
        mkdir -p $out

        cp -r *.kdl $out
        cp -r layouts $out
        cp -r yazi $out
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
