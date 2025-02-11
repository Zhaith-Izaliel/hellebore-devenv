{pkgs}: [
  (pkgs.callPackage ./builder.nix {
    grammar = {
      source = builtins.fetchTree {
        type = "github";
        owner = "IoeCmcomc";
        repo = "tree-sitter-mcfunction";
        rev = "5bf1f08320697c24f395af76422a845f9f627fb0";
      };

      name = "mcfunction";
    };
  })
]
