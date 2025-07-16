{
  stdenv,
  src,
  helix-driver,
  makeWrapper,
  lib,
}: let
  wrapperPath = lib.makeBinPath [helix-driver];
in
  stdenv.mkDerivation rec {
    inherit src;
    pname = "helix-zsh";
    version = src.shortRev;

    nativeBuildInputs = [
      makeWrapper
    ];

    dontBuild = true;

    installPhase = ''
      mkdir -p "$out/share/${pname}"
      cp helix_zsh.zsh "$out/share/${pname}/${pname}.plugin.zsh"
      chmod +x "$out/share/${pname}/${pname}.plugin.zsh"
    '';

    postFixup = ''
      wrapProgram $out/share/${pname}/${pname}.plugin.zsh --prefix PATH : "${wrapperPath}"
    '';
  }
