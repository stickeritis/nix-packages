# We take attribute sets of arguments. The first set are arguments
# that are constant between the models (such as the sticker2
# derivation to use). The second set of arguments defines specific
# models.

{ lib
, stdenvNoCC
, fetchurl

, dockerTools
, generateImages
, makeWrapper

, sticker
}:

{
# Word and tag embeddings as an attrset, containing the attributes:
#
# - embeds: Embedding file fixed-output derivation.
# - filename: Embedding file name in the model's sticker.conf
  wordEmbeds
, tagEmbeds ? null

# Short name of the model. E.g.: de-pos-ud.
, modelName

# Version of the model, typically a date. E.g.: 20190821
, version

, sha256
}:

rec {
  inherit modelName;

  dockerImage = lib.makeOverridable dockerTools.buildLayeredImage {
    name = "danieldk/sticker";
    tag = "${modelName}-${version}";
    contents = wrapper;
    maxLayers = 100;
  };

  model = stdenvNoCC.mkDerivation rec {
    inherit version;

    pname = "sticker-model-${modelName}";

    src = fetchurl {
      inherit sha256;

      url = let
        fullName = "${modelName}-${version}";
        in "https://github.com/stickeritis/sticker-models/releases/download/${fullName}/${fullName}.tar.gz";
    };

    preConfigure = ''
      substituteInPlace sticker.conf \
        --replace "${wordEmbeds.filename}" \
      "${wordEmbeds.embeds}"
    '' + stdenvNoCC.lib.optionalString (tagEmbeds != null) ''
      substituteInPlace sticker.conf \
        --replace "${tagEmbeds.filename}" \
      "${tagEmbeds.embeds}"
    '';

    installPhase = ''
      mkdir -p $out/share/sticker/models/${modelName}
      install -m 0644 *.conf *.graph *.labels *.shapes epoch-* $out/share/sticker/models/${modelName}
    '';

    meta = with stdenvNoCC.lib; {
      homepage = https://github.com/danieldk/sticker/;
      description = "Sticker ${modelName} model";
      license = licenses.unfreeRedistributable;
      maintainers = with maintainers; [ danieldk ];
      platforms = platforms.unix;
    };
  };

  vmImages = generateImages (import ../../nixos/vm-configuration.nix {
    runCommand = ''
      ${sticker}/bin/sticker server \
        --addr 0.0.0.0:4000 \
        "${model}/share/sticker/models/${modelName}/sticker.conf"
    '';
  });

  wrapper = stdenvNoCC.mkDerivation rec {
    inherit version;

    pname = "sticker-${modelName}";

    nativeBuildInputs = [ makeWrapper ];

    unpackPhase = "true";

    installPhase = ''
      makeWrapper ${sticker}/bin/sticker $out/bin/sticker-tag-${modelName} \
        --add-flags tag \
        --add-flags "${model}/share/sticker/models/${modelName}/sticker.conf"
      makeWrapper ${sticker}/bin/sticker $out/bin/sticker-server-${modelName} \
        --add-flags server \
        --add-flags "${model}/share/sticker/models/${modelName}/sticker.conf"
    '';

    meta = with stdenvNoCC.lib; {
      homepage = https://github.com/danieldk/sticker/;
      description = "Sticker ${modelName} model wrapper";
      license = licenses.unfreeRedistributable;
      maintainers = with maintainers; [ danieldk ];
      platforms = platforms.unix;
    };
  };
}
