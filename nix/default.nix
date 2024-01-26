{
  stdenv,
  lib,
  version ? "git"
}:

stdenv.mkDerivation {
  inherit version;

  pname = "helix-zhaith-configuration";

  src = lib.cleanSourceWith {
    filter = name: type: (type == "regular" ) && (
      (builtins.match ".*\.nix" name) == null
    );
    src = lib.cleanSource ../.;
  };

  installPhase = ''
    mkdir -p $out
    cp -r *.toml $out
  '';
}

