{ lib
, stdenvNoCC

, dockerTools
, makeWrapper

, sticker
}:

{
  # The pipeline name.
  name

  # The pipeline version.
, version

  # The pipeline models.
, models
}:

assert (builtins.isList models) && models != [];
assert builtins.all (m: m ? modelName) models;

let
  modelToConfig = model: "${model.model}/share/sticker/models/${model.modelName}/sticker.conf";
  modelFlags = lib.concatMapStrings (model: " --add-flags ${modelToConfig model}") models;
in rec {
  dockerImage = lib.makeOverridable dockerTools.buildLayeredImage {
    name = "danieldk/sticker";
    tag = "pipeline-${name}-${version}";
    contents = wrapper;
    maxLayers = 100;
  };

  wrapper = stdenvNoCC.mkDerivation rec {
    inherit version;

    pname = "sticker-pipeline-${name}";

    nativeBuildInputs = [ makeWrapper ];

    dontUnpack = true;

    installPhase = ''
      makeWrapper ${sticker}/bin/sticker $out/bin/sticker-tag-pipeline-${name} \
        --add-flags tag \
        ${modelFlags}
      makeWrapper ${sticker}/bin/sticker $out/bin/sticker-server-pipeline-${name} \
        --add-flags server \
        ${modelFlags}
    '';

    meta = with stdenvNoCC.lib; {
      homepage = https://github.com/danieldk/sticker/;
      description = "Sticker ${name} pipeline";
      license = licenses.unfreeRedistributable;
      maintainers = with maintainers; [ danieldk ];
      platforms = platforms.unix;
    };
  };
}
