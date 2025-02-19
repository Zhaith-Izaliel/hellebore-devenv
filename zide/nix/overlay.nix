{inputs}: final: prev: {
  zide = final.callPackage ./zide/zide.nix {
    src = inputs.zide;
  };
}
