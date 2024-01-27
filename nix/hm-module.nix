{package}: {
  config,
  pkgs,
  lib,
  stdenv,
  ...
}: let
  inherit (lib) mkEnableOption mkIf types mkOption;
  cfg = config.programs.helix.zhaith-configuration;

  extraLanguages = ''
    [language-server]
    vuels = { command = "vue-language-server", args = ["--stdio"], config = { typescript = { tsdk = "${volar}/lib/node_modules/typescript/lib/" } } }
  '';

  nodejs-servers = import ./nodejs {
    inherit pkgs stdenv;
    nodejs = pkgs.nodejs;
  };

  volar = nodejs-servers."@volar/vue-language-server".overrideAttrs (final: prev: {
    nativeBuildInputs = with pkgs; [
      typescript
    ];

    installPhase =
      prev.installPhase
      + ''
        mkdir -p $out/node_modules

        ln -s ${pkgs.typescript}/lib/node_modules/* $out/node_modules
      '';
  });
in {
  options.programs.helix.zhaith-configuration = {
    enable = mkEnableOption "Zhaith Izaliel's Helix configuration";

    defaultEditor =
      mkEnableOption null
      // {
        description = ''
          Whether to configure {command}`hx` as the default
          editor using the {env}`EDITOR` environment variable.
        '';
      };

    package = mkOption {
      default = package.override {inherit extraLanguages;};
      type = types.package;
      description = "Defines the package used to get Helix's configuration from.";
    };
  };

  config = mkIf cfg.enable {
    programs.helix = {
      inherit (cfg) enable defaultEditor;

      extraPackages = with pkgs; [
        # Language Servers
        nil
        emmet-ls
        nodePackages.pyright
        sumneko-lua-language-server
        rust-analyzer
        nodePackages.vscode-langservers-extracted # CSS, HTML, JSON, ESLint
        nodePackages.typescript-language-server
        python311Packages.mdformat
        nodePackages.bash-language-server
        haskell-language-server
        ccls
        gopls
        cmake-language-server
        ltex-ls
        nodejs-servers.stylelint-lsp
        nodejs-servers."@tailwindcss/language-server"
        volar

        # DAP
        lldb
        delve

        # Formatters
        alejandra
      ];
    };

    home.file.".config/helix/config.toml".source = "${cfg.package}/config.toml";
    home.file.".config/helix/languages.toml".source = "${cfg.package}/languages.toml";
  };
}
