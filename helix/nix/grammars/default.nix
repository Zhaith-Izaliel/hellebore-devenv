{pkgs}: final: prev: {
  mcfunction = pkgs.callPackage ./builder.nix {
    grammar = {
      source = builtins.fetchTree {
        type = "github";
        owner = "IoeCmcomc";
        repo = "tree-sitter-mcfunction";
        rev = "5bf1f08320697c24f395af76422a845f9f627fb0";
      };

      name = "mcfunction";
    };
  };

  gdshader = pkgs.callPackage ./builder.nix {
    grammar = {
      source = builtins.fetchTree {
        type = "github";
        owner = "GodOfAvacyn";
        repo = "tree-sitter-gdshader";
        rev = "ffd9f958df13cae04593781d7d2562295a872455";
      };

      name = "gdshader";
    };
  };
}
