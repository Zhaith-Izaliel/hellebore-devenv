{
  buildGoModule,
  fetchFromGitHub,
}:
buildGoModule {
  pname = "fusion";
  version = "";

  src = fetchFromGitHub {
    owner = "edgelaboratories";
    repo = "fusion";
    rev = "4965c468a21feb8eb54c1f2533a0bbbc95135e72";
    hash = "sha256-hx5FcLilCrACyaFiKuk50pZVt+c9fshoI1qMkxg14ls=";
  };

  vendorHash = "sha256-bpk9NjK4DnQnc0FkfPVICz5aFnKUOjMHR1TEunfmwu8=";
}
