{
  src,
  buildGoModule,
}:
buildGoModule {
  inherit src;
  pname = "ctags-lsp";
  version = "v0.5.0";

  vendorHash = null;
}
