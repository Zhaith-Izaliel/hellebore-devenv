{
  pkgs,
  lib,
}: {
  language-server.vuels.config.typescript.tsdk = "${pkgs.typescript}/lib/node_modules/typescript/lib/";
}
