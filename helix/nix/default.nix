{
  stdenv,
  lib,
  fusion,
  version ? "git",
  extraConfig ? {
    languages = "";
    config = "";
    ignores = "";
    themes = {};
    runtime = null;
  },
}: let
  inherit (lib) concatStringsSep optionalString mapAttrsToList;

  extraThemesInstall = concatStringsSep "\n" (mapAttrsToList (name: value: ''cat '${value}' > "$out/themes/${name}.toml"'') extraConfig.themes);

  finalIgnores =
    if extraConfig.ignores != ""
    then "echo '${extraConfig.ignores}' > $out/ignore"
    else "cp ignore $out/ignore";
in
  stdenv.mkDerivation {
    inherit version;

    pname = "helix-hellebore-dev-env";

    src = lib.cleanSource ../.;

    nativeBuildInputs = [
      fusion
    ];

    installPhase = concatStringsSep "\n" [
      ''
        runHook preInstall
        mkdir -p $out

        cp -r *.toml $out
        cp -r themes $out/themes
        cp -r runtime $out/runtime
      ''
      finalIgnores
      (optionalString (extraConfig.languages != "") "fusion toml languages.toml ${extraConfig.languages} -o $out/languages.toml")
      (optionalString (extraConfig.config != "") "fusion toml config.toml ${extraConfig.config} -o $out/config.toml")
      (optionalString (extraConfig.runtime != null) "cp -r ${extraConfig.runtime} $out/runtime")
      extraThemesInstall
      ''
        runHook postInstall
      ''
    ];
  }
