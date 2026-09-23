{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
}: stdenv.mkDerivation rec {
  pname = "cymbal";
  version = "0.16.2";

  # fetchurl, not fetchzip: the tarball holds a single bare file with no root dir,
  # which makes nix-prefetch-url --unpack emit a hash fetchzip can never match.
  src = fetchurl {
    url = "https://github.com/1broseidon/cymbal/releases/download/v${version}/cymbal_v${version}_linux_x86_64.tar.gz";
    hash = "sha256-8EYDVNi0KMvM4OkSSI4xTFqGF0pvYG6oHM9yGtjSCho=";
  };

  nativeBuildInputs = [autoPatchelfHook];

  # tarball has no root dir, so stdenv's unpack auto-detection finds none
  sourceRoot = ".";

  installPhase = ''
    install -Dm755 cymbal $out/bin/cymbal
  '';

  meta = {
    mainProgram = "cymbal";
    description = "Fast, language-agnostic code navigator (tree-sitter + SQLite index)";
    homepage = "https://github.com/1broseidon/cymbal";
    license = lib.licenses.mit;
    platforms = ["x86_64-linux"];
  };
}