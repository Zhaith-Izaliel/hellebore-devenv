{
  stdenv,
  writeTextFile,
  lib,
  fusion,
  version ? "git",
  extraLanguages ? "",
  extraConfig ? "",
}: let
  extraLanguagesFile = writeTextFile {
    name = "helix-zhaith-extra-languages-file.toml";
    text = extraLanguages;
  };

  extraConfigFile = writeTextFile {
    name = "helix-zhaith-extra-languages-file.toml";
    text = extraConfig;
  };
in
  stdenv.mkDerivation {
    inherit version;

    pname = "helix-zhaith-configuration";

    src = lib.cleanSourceWith {
      filter = name: type:
        (type == "regular")
        && (
          (builtins.match ".*\.nix" name) == null
        );
      src = lib.cleanSource ../.;
    };

    nativeBuildInputs = [
      fusion
    ];

    installPhase = lib.concatStringsSep "\n" [
      "mkdir -p $out"
      "cp -r *.toml $out"
      (lib.optionalString (extraLanguages != "") "fusion toml languages.toml ${extraLanguagesFile} -o $out/languages.toml")
      (lib.optionalString (extraConfig != "") "fusion toml config.toml ${extraConfigFile} -o $out/config.toml")
    ];
  }
