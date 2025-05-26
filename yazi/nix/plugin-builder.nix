{
  src,
  pname,
  stdenvNoCC,
}:
stdenvNoCC.mkDerivation {
  inherit pname src;
  version = src.shortRev;

  dontBuild = true;
  dontConfigure = true;
  installPhase = ''
    mkdir -p $out
    cp -r * $out
  '';
}
