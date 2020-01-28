{ lib
, stdenvNoCC
, fetchurl

, dockerTools
, makeWrapper

, sticker2

# Short name of the model. E.g.: nl-ud.
, modelName

# Version of the model, typically a date. E.g.: 20200128
, version

, sha256
}:

rec {
  inherit modelName;

  dockerImage = lib.makeOverridable dockerTools.buildLayeredImage {
    name = "danieldk/sticker2";
    tag = "${modelName}-${version}";
    contents = wrapper;
    maxLayers = 100;
  };

  model = stdenvNoCC.mkDerivation rec {
    inherit version;

    pname = "sticker2-model-${modelName}";

    src = fetchurl {
      inherit sha256;

      url = let
        fullName = "${modelName}-${version}";
        in "https://github.com/stickeritis/sticker2-models/releases/download/${fullName}/${fullName}.tar.gz";
    };

    installPhase = ''
      mkdir -p $out/share/sticker2/models/${modelName}
      install -m 0644 * $out/share/sticker2/models/${modelName}
    '';

    meta = with stdenvNoCC.lib; {
      homepage = https://github.com/danieldk/sticker/;
      description = "Sticker ${modelName} model";
      license = licenses.unfreeRedistributable;
      maintainers = with maintainers; [ danieldk ];
      platforms = platforms.unix;
    };
  };

  wrapper = stdenvNoCC.mkDerivation rec {
    inherit version;

    pname = "sticker-${modelName}";

    nativeBuildInputs = [ makeWrapper ];

    unpackPhase = "true";

    installPhase = ''
      makeWrapper ${sticker2}/bin/sticker2 $out/bin/sticker2-annotate-${modelName} \
        --add-flags annotate \
        --add-flags "${model}/share/sticker2/models/${modelName}/sticker.conf"
      makeWrapper ${sticker2}/bin/sticker2 $out/bin/sticker2-server-${modelName} \
        --add-flags server \
        --add-flags "${model}/share/sticker2/models/${modelName}/sticker.conf"
    '';

    meta = with stdenvNoCC.lib; {
      homepage = https://github.com/danieldk/sticker/;
      description = "sticker2 ${modelName} model wrapper";
      license = licenses.unfreeRedistributable;
      maintainers = with maintainers; [ danieldk ];
      platforms = platforms.unix;
    };
  };
}
