{
  stdenv,
  fetchFromGitHub,
  makeWrapper,
  python3,
}:
stdenv.mkDerivation rec {
  pname = "interactive-html-bom";
  version = "2.9.0";

  src = fetchFromGitHub {
    owner = "openscopeproject";
    repo = "InteractiveHtmlBom";
    rev = "v${version}";
    hash = "sha256-jUHEI0dWMFPQlXei3+0m1ruHzpG1hcRnxptNOXzXDqQ=";
  };

  nativeBuildInputs = [makeWrapper];

  prePatch = ''
    rm InteractiveHtmlBom/__init__.py
    rm -r InteractiveHtmlBom/dialog

    sed -i '/import wx/d' $(find . -name '*.py')
    sed -i '/from wx/d' $(find . -name '*.py')
    sed -i '/from .. import dialog/d' $(find . -name '*.py')
    sed -i '/from ..dialog/d' $(find . -name '*.py')
    sed -i 's/elif hasattr(wx, "DisableAsserts")/elif False/g' $(find . -name '*.py')
  '';

  installPhase = let
    python3WithKicad = python3.withPackages (p:
      with p; [
        kicad
      ]);
  in ''
    mkdir -p $out/opt
    mkdir -p $out/bin

    cp -r InteractiveHtmlBom $out/opt

    makeWrapper \
      ${python3WithKicad}/bin/python \
      $out/bin/generate_interactive_bom \
      --set INTERACTIVE_HTML_BOM_NO_DISPLAY 1 \
      --set INTERACTIVE_HTML_BOM_CLI_MODE 1 \
      --add-flags $out/opt/InteractiveHtmlBom/generate_interactive_bom.py
  '';
}
