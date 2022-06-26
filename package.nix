{ lib
, stdenv
, fetchFromGitHub
, makeWrapper
, python3
}:

stdenv.mkDerivation rec {
  pname = "interactive-html-bom";
  version = "2.5.0";

  src = fetchFromGitHub {
    owner = "openscopeproject";
    repo = "InteractiveHtmlBom";
    rev = "v${version}";
    sha256 = "sha256-ZpytvUnQnjJ90mxMe4G3X8T0TUqz7DW9cxOLtJxn55w=";
  };

  nativeBuildInputs = [ makeWrapper ];

  installPhase =
    let
      python3WithWx = python3.withPackages (p: with p; [
        wxPython_4_1
      ]);
    in
    ''
      mkdir -p $out/opt
      mkdir -p $out/bin

      cp -r $src/InteractiveHtmlBom $out/opt

      makeWrapper \
        ${python3WithWx}/bin/python \
        $out/bin/generate_interactive_bom \
        --set INTERACTIVE_HTML_BOM_NO_DISPLAY 1 \
        --set INTERACTIVE_HTML_BOM_CLI_MODE 1 \
        --add-flags $out/opt/InteractiveHtmlBom/generate_interactive_bom.py
    '';
}
