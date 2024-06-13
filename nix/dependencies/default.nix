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
    python311Packages.mdformat
    gotools
    nodePackages.prettier
    stylish-haskell
    google-java-format
    stylua
    shfmt
  ];

  language-servers = with pkgs; [
    simple-completion-language-server
    jdt-language-server
    (taplo.override {withLsp = true;})
    nil
    emmet-ls
    sumneko-lua-language-server
    rust-analyzer
    nodePackages.pyright
    nodePackages.vscode-langservers-extracted # CSS, HTML, JSON, ESLint
    nodePackages.typescript-language-server
    nodePackages.graphql-language-service-cli
    nodePackages.bash-language-server
    tailwindcss-language-server
    texlab
    haskell-language-server
    marksman
    gopls
    cmake-language-server
    ltex-ls
    ccls
    nodejs-packages.stylelint-lsp
    nodejs-packages."@vue/language-server"
  ];

  debug-adapters = with pkgs; [
    lldb
    delve
  ];

  other-packages = with pkgs; [
    wl-clipboard
  ];
}
