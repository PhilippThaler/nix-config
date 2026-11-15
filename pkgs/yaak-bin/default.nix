{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  wrapGAppsHook3,
  makeWrapper,
  cairo,
  dbus,
  fontconfig,
  gdk-pixbuf,
  glib,
  gtk3,
  libsoup_3,
  webkitgtk_4_1,
  zlib,
}:
stdenv.mkDerivation rec {
  pname = "yaak-bin";
  version = "2026.9.1";

  # upstream .deb instead of pkgs.yaak: the Tauri source build is a 30-60 min
  # rust+npm+wasm compile that cache.nixos.org never has ready
  src = fetchurl {
    url = "https://github.com/mountain-loop/yaak/releases/download/v${version}/yaak_${version}_amd64.deb";
    hash = "sha256-1n0CnvT1vQpI2d2zXFLHgQp1JOSaWqPXoEAmoN9c0V4=";
  };

  nativeBuildInputs = [autoPatchelfHook wrapGAppsHook3 makeWrapper];

  buildInputs = [
    cairo
    dbus
    fontconfig
    gdk-pixbuf
    glib
    gtk3
    libsoup_3
    stdenv.cc.cc.lib
    webkitgtk_4_1
    zlib
  ];

  # .deb wraps the payload in an ar archive; data.tar.gz holds a plain usr/ tree
  unpackPhase = ''
    runHook preUnpack
    ar x $src data.tar.gz
    tar -xzf data.tar.gz
    runHook postUnpack
  '';

  dontBuild = true;
  dontConfigure = true;

  # tauri resolves resources as $exe_dir/../lib/<product>, so keep bin/ and lib/ siblings
  installPhase = ''
    runHook preInstall
    mkdir -p $out
    cp -r usr/* $out/
    runHook postInstall
  '';

  postFixup = ''
    makeWrapper $out/bin/yaak-app-client $out/bin/yaak \
      "''${gappsWrapperArgs[@]}"
  '';

  meta = {
    description = "Desktop API client for organizing and executing REST, GraphQL, and gRPC requests (prebuilt)";
    homepage = "https://yaak.app/";
    changelog = "https://github.com/mountain-loop/yaak/releases/tag/v${version}";
    license = lib.licenses.mit;
    mainProgram = "yaak";
    # the bundled vendor/node/yaaknode is x86_64
    platforms = ["x86_64-linux"];
    sourceProvenance = [lib.sourceTypes.binaryNativeCode];
  };
}
