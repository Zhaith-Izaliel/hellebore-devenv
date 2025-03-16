{
  pkgs,
  stdenv,
  lib,
}: let
  nodejs-packages = import ./nodejs {
    inherit pkgs stdenv;
    nodejs = pkgs.nodejs;
  };
in {
  formatters = with pkgs; [
    alejandra
    pandoc
    gotools
    nodePackages.prettier
    stylish-haskell
    google-java-format
    stylua
    shfmt
    gdtoolkit_4
    black
  ];

  language-servers =
    (with pkgs; [
      simple-completion-language-server
      jdt-language-server
      nil
      nixd
      emmet-ls
      sumneko-lua-language-server
      rust-analyzer
      pyright
      nodePackages.vscode-langservers-extracted # CSS, HTML, JSON, ESLint
      nodePackages.typescript-language-server
      # nodePackages.graphql-language-service-cli # TEMP: Currently broken in unstable
      tailwindcss-language-server
      texlab
      haskell-language-server
      clang-tools
      marksman
      gopls
      cmake-language-server
      ltex-ls
      ccls
      biome
      ctags-lsp
      typos-lsp
    ])
    ++ [
      (pkgs.taplo.override {withLsp = true;})
      (
        if (builtins.hasAttr "bash-language-server" pkgs)
        then pkgs.bash-language-server
        else pkgs.nodePackages.bash-language-server
      )
      nodejs-packages.stylelint-lsp
      nodejs-packages."@vue/language-server"
      nodejs-packages."@spyglassmc/language-server"
    ];

  debug-adapters = with pkgs; [
    lldb
    delve
  ];

  other-packages = with pkgs; [
    wl-clipboard
    netcat
    universal-ctags
  ];
}
