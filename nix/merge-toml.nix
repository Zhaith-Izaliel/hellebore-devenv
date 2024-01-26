{ fetchFromGitHub, rustPlatform }:

rustPlatform.buildRustPackage rec {
  pname = "toml-merge";
  version = "c44eee7";

  src = fetchFromGitHub {
    owner = "mrnerdhair";
    repo = pname;
    rev = version;
    hash = "";
  };

  cargoHash = "";
}

