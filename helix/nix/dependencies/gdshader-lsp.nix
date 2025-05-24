{
  rustPlatform,
  src,
}:
rustPlatform.buildRustPackage {
  inherit src;
  pname = "gdshader-lsp";
  version = "f3847df";

  cargoHash = "sha256-FP3SMcafLbz3jqKTunCi4Z1CeZADLmmsIyWHQICmi8o=";

  meta.mainProgram = "gdshader-lsp";
}
