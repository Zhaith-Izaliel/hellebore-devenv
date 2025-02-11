{
  src,
  buildGoModule,
}:
buildGoModule {
  inherit src;
  pname = "mcfunction-lsp";
  version = "3bc37bc271dce1a3a3a331149cdb17447054ddb6";

  vendorHash = "sha256-qkBpSVLWZPRgS9bqOVUWHpyj8z/nheQJON3vJOwPUj4=";
}
