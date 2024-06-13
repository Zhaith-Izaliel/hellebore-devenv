{
  pkgs,
  lib,
}: {
  language-server.typescript-language-server.config.plugins = [
    {
      name = "@vue/typescript-plugin";
      languages = ["vue"];
      location = "${pkgs.nodePackages.volar}/lib/node_modules/@volar/vue-language-server/";
    }
  ];
}
