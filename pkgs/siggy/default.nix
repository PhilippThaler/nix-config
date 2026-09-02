{
  lib,
  fetchurl,
  stdenv,
  autoPatchelfHook,
}:
stdenv.mkDerivation {
  pname = "siggy";
  version = "1.15.0";
  src = fetchurl {
    url = "https://github.com/johnsideserf/siggy/releases/download/v1.15.0/siggy-v1.15.0-x86_64-unknown-linux-gnu.tar.gz";
    sha256 = "sha256-WG01x7205xvqVJJ9xafgWneTCTxHS9yQNuhrC5QT/H4=";
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
