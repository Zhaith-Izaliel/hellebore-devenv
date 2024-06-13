{
  pkgs,
  lib,
  nodejs-packages,
}: {
  language-server.typescript-language-server.config.plugins = [
    {
      name = "@vue/typescript-plugin";
      languages = ["vue"];
      location = "${nodejs-packages."@vue/language-server"}/lib/node_modules/@volar/vue-language-server/";
    }
  ];
}
