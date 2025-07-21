{
  rustPlatform,
  src,
  openssl,
  pkg-config,
}:
rustPlatform.buildRustPackage {
  inherit src;
  pname = "zeco";
  version = src.shortRev;

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    openssl
  ];

  cargoHash = "sha256-l5LxZyi1jOVa4a0JzCLXMQksplre559B9ofJoluVZio=";

  meta.mainProgram = "zeco";
}
