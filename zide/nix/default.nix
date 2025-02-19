{
  stdenv,
  lib,
  version ? "git",
  zide,
}:
stdenv.mkDerivation {
  inherit version;
  src = lib.cleanSource ../.;

  pname = "zide-hellebore-dev-env";

  buildInputs = [
    zide
  ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out
    mkdir -p $out/layouts
    cp -r layouts/* $out/layouts
    cp -r ${zide}/* $out
    runHook postInstall
  '';
}
