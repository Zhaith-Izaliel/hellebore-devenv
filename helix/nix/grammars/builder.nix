{
  stdenv,
  lib,
  grammar,
}:
stdenv.mkDerivation {
  # see https://github.com/NixOS/nixpkgs/blob/fbdd1a7c0bc29af5325e0d7dd70e804a972eb465/pkgs/development/tools/parsing/tree-sitter/grammar.nix

  pname = "helix-tree-sitter-${grammar.name}";
  version = grammar.source.rev;

  src = grammar.source;
  sourceRoot =
    if builtins.hasAttr "subpath" grammar.source
    then "source/${grammar.source.subpath}"
    else "source";

  dontConfigure = true;

  FLAGS = [
    "-Isrc"
    "-g"
    "-O3"
    "-fPIC"
    "-fno-exceptions"
    "-Wl,-z,relro,-z,now"
  ];

  NAME = grammar.name;

  buildPhase = ''
    runHook preBuild

    if [[ -e src/scanner.cc ]]; then
      $CXX -c src/scanner.cc -o scanner.o $FLAGS
    elif [[ -e src/scanner.c ]]; then
      $CC -c src/scanner.c -o scanner.o $FLAGS
    fi

    $CC -c src/parser.c -o parser.o $FLAGS
    $CXX -shared -o $NAME.so *.o

    ls -al

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir $out
    mv $NAME.so $out/
    runHook postInstall
  '';

  # Strip failed on darwin: strip: error: symbols referenced by indirect symbol table entries that can't be stripped
  fixupPhase = lib.optionalString stdenv.isLinux ''
    runHook preFixup
    $STRIP $out/$NAME.so
    runHook postFixup
  '';
}
