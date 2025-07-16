{
  rustPlatform,
  helix,
  src,
}:
rustPlatform.buildRustPackage {
  pname = "helix-driver";

  src = "${src}/helix-driver";

  version = src.shortRev;

  useFetchCargoVendor = true;

  preBuild = ''
    ln -s ${helix.src}/languages.toml /build/helix-driver-${src.shortRev}-vendor
    ln -s ${helix.src}/theme.toml /build/helix-driver-${src.shortRev}-vendor
    ln -s ${helix.src}/base16_theme.toml /build/helix-driver-${src.shortRev}-vendor
  '';

  # Helix attempts to reach out to the network and get the grammars. Nix doesn't allow this.
  HELIX_DISABLE_AUTO_GRAMMAR_BUILD = "1";

  doCheck = false;
  strictDeps = true;

  postPatch = ''
    # Replace git dependency with path dependency
    sed -i 's|helix-core = { git = "https://github.com/helix-editor/helix" }|helix-core = { path = "${helix}" }|' Cargo.toml
    sed -i 's|helix-view = { git = "https://github.com/helix-editor/helix" }|helix-view = { path = "${helix}" }|' Cargo.toml
    sed -i 's|helix-loader = { git = "https://github.com/helix-editor/helix" }|helix-loader = { path = "${helix}" }|' Cargo.toml
    sed -i 's|helix-term = { git = "https://github.com/helix-editor/helix" }|helix-term = { path = "${helix}" }|' Cargo.toml
    sed -i 's|helix-event = { git = "https://github.com/helix-editor/helix" }|helix-event = { path = "${helix}" }|' Cargo.toml
  '';

  cargoHash = "sha256-8aBzee9MjT/PRFTis9LJZaFsnRUIM8e+GF5ndeRE+IA=";
}
