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

  cargoHash = "sha256-aiHBAQC/NwIud91p7sMXBYKEKs5mDHbDznid+tTC7Uc=";

  meta.mainProgram = "zeco";
}
