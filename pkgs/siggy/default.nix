{
  lib,
  fetchurl,
  stdenv,
  autoPatchelfHook,
}:
stdenv.mkDerivation {
  pname = "siggy";
  version = "1.14.2";
  src = fetchurl {
    url = "https://github.com/johnsideserf/siggy/releases/download/v1.14.2/siggy-v1.14.2-x86_64-unknown-linux-gnu.tar.gz";
    sha256 = "sha256-DuVtOgdwMlh9PW2i3DTcKBodcsubkDsOCgtCKFAU2h0=";
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
