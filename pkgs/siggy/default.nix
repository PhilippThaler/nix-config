{
  lib,
  fetchurl,
  stdenv,
  autoPatchelfHook,
}:
stdenv.mkDerivation {
  pname = "siggy";
  version = "1.14.3";
  src = fetchurl {
    url = "https://github.com/johnsideserf/siggy/releases/download/v1.14.3/siggy-v1.14.3-x86_64-unknown-linux-gnu.tar.gz";
    sha256 = "sha256-QsmL1hO+mnDFz9P2q11e/qCq6rSbvwwDXasAmFZOt1I=";
  };
  sourceRoot = ".";
  nativeBuildInputs = [autoPatchelfHook];
  buildInputs = [stdenv.cc.cc.lib];
  installPhase = ''
    install -Dm755 siggy $out/bin/siggy
  '';
  # Prebuilt release binary (glibc, x86_64); talks to signal-cli at runtime
  meta = {
    description = "Terminal-based Signal messenger client with vim keybindings";
    license = lib.licenses.agpl3Only;
    mainProgram = "siggy";
    platforms = lib.platforms.linux;
  };
}
