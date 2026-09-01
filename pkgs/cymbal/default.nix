{
  lib,
  stdenv,
  fetchzip,
  autoPatchelfHook,
}: stdenv.mkDerivation rec {
  pname = "cymbal";
  version = "0.14.0";

  src = fetchzip {
    url = "https://github.com/1broseidon/cymbal/releases/download/v${version}/cymbal_v${version}_linux_x86_64.tar.gz";
    hash = "sha256-YxIy+WU2yw1h5SCobnA9h6+5c4zYpLWY/1STuqZVIfY=";
  };

  nativeBuildInputs = [autoPatchelfHook];

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