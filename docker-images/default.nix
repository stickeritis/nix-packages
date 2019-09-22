{ lib
, dockerTools

  # Sticker model set.
, models

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
in
builtins.mapAttrs (n: v: stickerImage n v.wrapper.version v.wrapper)
  (lib.filterAttrs isModel models)
