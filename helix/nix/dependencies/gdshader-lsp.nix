{
  rustPlatform,
  src,
}:
rustPlatform.buildRustPackage {
  inherit src;
  pname = "gdshader-lsp";
  version = "f3847df";

  cargoHash = "sha256-kEHqmuuh+84wJ6yjcqGvSSSVEixGbSd9qE6Fg1IE/08=";

  meta.mainProgram = "gdshader-lsp";
}
