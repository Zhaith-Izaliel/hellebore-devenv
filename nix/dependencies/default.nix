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
  ];

  language-servers = with pkgs; [
    simple-completion-language-server
    nil
    emmet-ls
    nodePackages.pyright
    sumneko-lua-language-server
    rust-analyzer
    nodePackages.vscode-langservers-extracted # CSS, HTML, JSON, ESLint
    nodePackages.typescript-language-server
    nodePackages.volar
    tailwindcss-language-server
    texlab
    nodePackages.bash-language-server
    haskell-language-server
    rocmPackages.llvm.clang-tools-extra
    marksman
    gopls
    cmake-language-server
    ltex-ls
    nodejs-packages.stylelint-lsp
  ];

  debug-adapters = with pkgs; [
    lldb
    delve
  ];

  other-packages = with pkgs; [
    wl-clipboard
  ];
}
