{
  pkgs,
  lib,
}: let
  inherit (lib) getExe;
in ''
  [language-server.vuels.config.typescript]
  tsdk = "${pkgs.typescript}/lib/node_modules/typescript/lib/"

  [language-server.scls]
  command = "${pkgs.simple-completion-language-server}/bin/simple-completion-language-server"

  [language-server.nil]
  command = "${getExe pkgs.nil}"

  [language-server.taplo]
  command = "${getExe pkgs.taplo}"

  [[language]]
  name = "toml"
  formatter = { command = "${getExe pkgs.taplo}", args = ["format", "-"] }
''
