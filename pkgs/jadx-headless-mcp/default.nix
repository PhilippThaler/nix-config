{
  lib,
  stdenvNoCC,
  fetchurl,
}:
stdenvNoCC.mkDerivation rec {
  pname = "jadx-headless-mcp";
  version = "0.7.1";

  # REA 6.8.0 pins this exact artifact and rejects other builds
  src = fetchurl {
    url = "https://github.com/1013503897/jadx-headless-mcp/releases/download/v${version}/jadx-headless-mcp-${version}-all.jar";
    hash = "sha256-bl6s9QC2QpK/tzxJeXwZWPbuRGRuQ+hoA5rn/rVz/3U=";
  };

  dontUnpack = true;

  installPhase = ''
    runHook preInstall
    install -Dm444 $src $out/share/java/${pname}-${version}-all.jar
    runHook postInstall
  '';

  meta = {
    description = "Headless JADX MCP server used by REA's Android provider";
    homepage = "https://github.com/1013503897/jadx-headless-mcp";
    license = lib.licenses.asl20;
    platforms = lib.platforms.all;
  };
}
