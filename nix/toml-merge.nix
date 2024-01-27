{ fetchFromGitHub, rustPlatform }:

rustPlatform.buildRustPackage rec {
  pname = "toml-merge";
  version = "c44eee7";

  src = fetchFromGitHub {
    owner = "mrnerdhair";
    repo = pname;
    rev = version;
    hash = "sha256-+fVqU29xJOas5ktwT1hy4cHfMdpKvowLffoY+x6/X54=";
  };

  cargoHash = "sha256-g5i1/NQ1gVajpbxpQiGj8vqmbURltiSV2aLDkA4DL+U=";
}

