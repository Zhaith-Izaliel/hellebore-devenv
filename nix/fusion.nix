{
  buildGoModule,
  src,
}:
buildGoModule rec {
  inherit src;

  pname = "fusion";
  version = src.shortRev;
}
