{
  lib,
  stdenvNoCC,
  fetchurl,
  cacert,
  makeWrapper,
  nodejs_22,
  procps,
}:
let
  version = "6.8.0";

  src = fetchurl {
    url = "https://registry.npmjs.org/rea-agents/-/rea-agents-${version}.tgz";
    hash = "sha256-jVQux2qcs1BYS2CmycCIcG/4EtW7WwlMIMlbbcJWmLs=";
  };

  # A lockfile-generated tree fails npm's platform check on foreign-arch
  # optional deps, so vendor the registry install directly as a fixed-output path
  nodeDeps = stdenvNoCC.mkDerivation {
    pname = "rea-agents-${version}-node-deps";
    inherit src version;

    nativeBuildInputs = [nodejs_22 cacert];
    dontPatchShebangs = true;
    dontFixup = true;

    buildPhase = ''
      runHook preBuild
      export HOME=$TMPDIR
      cp -r . $TMPDIR/pkg
      cd $TMPDIR/pkg
      # npm 10 aborts on REA's `overrides`, which point at dev-only packages
      node -e "const fs=require('fs');const p=JSON.parse(fs.readFileSync('package.json','utf8'));delete p.devDependencies;delete p.overrides;fs.writeFileSync('package.json',JSON.stringify(p,null,2))"
      npm install --omit=dev --ignore-scripts --no-audit --no-fund
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      mkdir -p $out
      cp -r node_modules $out/node_modules
      runHook postInstall
    '';

    outputHashMode = "recursive";
    outputHash = "sha256-BROS6i0lSZJN7huEj/ykH5LOlo6K4pXJiR66NjTZ6Oc=";
  };
in
stdenvNoCC.mkDerivation {
  pname = "rea-agents";
  inherit version src;

  nativeBuildInputs = [makeWrapper];

  dontBuild = true;
  dontPatchShebangs = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/node_modules/rea-agents $out/bin
    cp -r . $out/lib/node_modules/rea-agents
    rm -rf $out/lib/node_modules/rea-agents/node_modules
    cp -r ${nodeDeps}/node_modules $out/lib/node_modules/rea-agents/node_modules

    # REA refuses to launch supervised children (Ghidra, JADX, static JS
    # analysis) unless a procps-compatible ps is on its PATH
    for bin in rea rea-agents; do
      makeWrapper ${nodejs_22}/bin/node $out/bin/$bin \
        --add-flags $out/lib/node_modules/rea-agents/scripts/rea.mjs \
        --prefix PATH : ${lib.makeBinPath [nodejs_22 procps]}
    done

    runHook postInstall
  '';

  meta = {
    description = "MCP tooling for reverse engineering apps, binaries and websites from agents";
    homepage = "https://rea.tools/";
    license = lib.licenses.mit;
    mainProgram = "rea";
    platforms = lib.platforms.linux;
  };
}
