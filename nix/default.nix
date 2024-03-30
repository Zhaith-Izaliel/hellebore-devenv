{
  stdenv,
  writeTextFile,
  lib,
  fusion,
  version ? "git",
  extraLanguages ? "",
  extraConfig ? "",
  extraThemes ? [],
}: let
  extraLanguagesFile = writeTextFile {
    name = "helix-zhaith-extra-languages-file.toml";
    text = extraLanguages;
  };

  extraConfigFile = writeTextFile {
    name = "helix-zhaith-extra-config-file.toml";
    text = extraConfig;
  };
in
  stdenv.mkDerivation {
    inherit version;

    pname = "helix-zhaith-configuration";

    src = lib.cleanSource ../.;

    nativeBuildInputs = [
      fusion
    ];

    installPhase = ''
      runHook preInstall

      mkdir -p $out
      cp -r *.toml $out
      cp -r themes $out/themes

      runHook postInstall
    '';

    postInstallPhase = lib.concatStringsSep "\n" [
      (lib.optionalString (extraLanguages != "") "fusion toml languages.toml ${extraLanguagesFile} -o $out/languages.toml")
      (lib.optionalString (extraConfig != "") "fusion toml config.toml ${extraConfigFile} -o $out/config.toml")

    ];
  }
