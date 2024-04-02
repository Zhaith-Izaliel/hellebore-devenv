{
  pkgs,
  lib,
}: let
  inherit (lib) getExe;
in ''
  [language-server.vuels.config.typescript]
  tsdk = "${pkgs.typescript}/lib/node_modules/typescript/lib/"
''
