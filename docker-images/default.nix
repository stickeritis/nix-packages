{ lib
, dockerTools

  # Sticker model set.
, models

  # Sticker pipeline set.
, pipelines

  # Docker image name.
, imageName ? "danieldk/sticker"

  # The maximum number of layers in a docker image.
, maxLayers ? 100
}:

let
  stickerImage = tagPrefix: version: wrapper:
    dockerTools.buildLayeredImage {
      inherit maxLayers;

      name = imageName;
      tag = "${tagPrefix}-${version}";
      contents = wrapper;
    };
  isModel = _: v: builtins.isAttrs v && v ? "wrapper" && v ? "model";
  isPipeline = _: v: lib.isDerivation v;
in
{
  # Model Docker images
  models = builtins.mapAttrs (n: v: stickerImage n v.wrapper.version v.wrapper)
    (lib.filterAttrs isModel models);

  # Pipeline Docker images
  pipelines = builtins.mapAttrs (n: v: stickerImage "pipeline-${n}" v.version v)
    (lib.filterAttrs isPipeline pipelines);
}
