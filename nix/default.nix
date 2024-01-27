{
  stdenv,
  lib,
  toml-merge,
  version ? "git",
  extraLanguages ? "",  
  extraConfig ? "",
}:

let
  extraLanguagesFile = builtins.toFile "helix-zhaith-extra-languages-file.toml" extraLanguages;
  extraConfigFile= builtins.toFile "helix-zhaith-extra-languages-file.toml" extraConfig;
in
stdenv.mkDerivation {
  inherit version;

  pname = "helix-zhaith-configuration";

  src = lib.cleanSourceWith {
    filter = name: type: (type == "regular" ) && (
      (builtins.match ".*\.nix" name) == null
    );
    src = lib.cleanSource ../.;
  };

  nativeBuildInputs = [
    toml-merge
  ];

  installPhase = lib.concatStringsSep "\n" [ 
    "mkdir -p $out"
    "cp -r *.toml $out"
    (lib.optionalString (extraLanguages != "") "toml-merge languages.toml ${extraLanguagesFile} > $out/languages.toml")
    (lib.optionalString (extraConfig != "") "toml-merge config.toml ${extraConfigFile} > $out/config.toml")
  ];
}

