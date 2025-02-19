{
  stdenv,
  version ? "git",
  src,
}:
stdenv.mkDerivation {
  inherit version src;
  pname = "zide";

  installPhase = ''
    runHook preInstall
    mkdir -p $out
    cp -r * $out
    runHook postInstall
  '';
}
