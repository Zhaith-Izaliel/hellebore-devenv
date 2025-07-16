{
  stdenv,
  src,
}:
stdenv.mkDerivation rec {
  inherit src;
  pname = "helix-zsh";
  version = src.shortRev;

  dontBuild = true;

  installPhase = ''
    mkdir -p "$out/share/${pname}"
    cp helix_zsh.zsh "$out/share/${pname}/${pname}.plugin.zsh"
    chmod +x "$out/share/${pname}/${pname}.plugin.zsh"
  '';
}
