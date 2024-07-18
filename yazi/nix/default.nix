{
  stdenv,
  lib,
  fusion,
  version ? "git",
  extraConfig ? {
    theme = "";
    keymap = "";
    settings = "";
    flavors = {};
    plugins = {};
    initLua = "";
  },
  installSideBar ? false,
}: let
  inherit (lib) concatStringsSep optionalString mapAttrsToList;
  installFlavorsOrPlugins = attrs: type:
    optionalString (attrs != {})
    (
      concatStringsSep "\n" (
        mapAttrsToList
        (name: value: ''cp -r "${value.value}" "$out/${type}/${name}"'')
        attrs
      )
    );
  finalFlavors = installFlavorsOrPlugins extraConfig.flavors "flavors";
  finalPlugins = installFlavorsOrPlugins extraConfig.plugins "plugins";
in
  stdenv.mkDerivation {
    inherit version;

    pname = "yazi-hellebore-dev-env";

    src = lib.cleanSource ../.;

    nativeBuildInputs = [
      fusion
    ];

    installPhase = concatStringsSep "\n" [
      ''
        runHook preInstall
        mkdir -p $out

        cp -r *.toml $out
        cp -r plugins $out
        cp -r flavors $out
      ''
      (optionalString (extraConfig.theme != "") "fusion toml theme.toml ${extraConfig.theme} -o $out/theme.toml")
      (optionalString (extraConfig.settings != "") "fusion toml yazi.toml ${extraConfig.settings} -o $out/yazi.toml")
      (optionalString (extraConfig.keymap != "") "fusion toml keymap.toml ${extraConfig.keymap} -o $out/keymap.toml")
      (
        if (extraConfig.initLua != "")
        then ''
          cat ${extraConfig.initLua} > $out/init.lua
        ''
        else ''
          cp -r init.lua $out/init.lua
        ''
      )
      finalFlavors
      finalPlugins
      (
        optionalString installSideBar
        ''
          cp -r sidebar $out
          cp -r $out/keymap.toml $out/sidebar
          cp -r $out/theme.toml $out/sidebar
          cp -r $out/flavors $out/sidebar
          fusion toml $out/yazi.toml sidebar/yazi.toml -o $out/sidebar/yazi.toml
        ''
      )
      ''
        runHook postInstall
      ''
    ];
  }
