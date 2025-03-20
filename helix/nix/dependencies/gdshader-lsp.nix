{
  rustPlatform,
  src,
}:
rustPlatform.buildRustPackage {
  inherit src;
  pname = "gdshader-lsp";
  version = "f3847df";

  cargoHash = "";

  meta.mainProgram = "gdshader-lsp";
}
