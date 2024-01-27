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
    python311Packages.mdformat
    nodePackages.bash-language-server
    haskell-language-server
    ccls
    gopls
    cmake-language-server
    ltex-ls

    (pkgs.commitlint.overrideAttrs
    (final: prev: {
      nativeBuildInputs = [
        nodejs-packages."@commitlint/config-conventional"
        nodejs-packages.commitlint-format-json
      ];
      installPhase =
        prev.installPhase
        + ''
          mkdir -p $out/node_modules

          ln -s ${nodejs-packages."@commitlint/config-conventional"}/lib/node_modules/* $out/node_modules
        '';
    }))
  ];

  debug-adapters = with pkgs; [
    lldb
    delve
  ];
}
