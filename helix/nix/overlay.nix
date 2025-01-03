{inputs}: final: prev: {
  simple-completion-language-server = inputs.simple-completion-language-server.defaultPackage.${final.stdenv.hostPlatform.system};
  ctags-lsp = final.callPackage ./dependencies/ctags-lsp.nix {src = inputs.ctags-lsp;};
}
