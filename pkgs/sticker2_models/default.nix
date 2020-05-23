{ lib, recurseIntoAttrs, stdenvNoCC, fetchurl, dockerTools, makeWrapper, sticker2 }:

let
  stickerModel = import ./model.nix {
    inherit lib stdenvNoCC fetchurl dockerTools makeWrapper sticker2;
  };
in lib.mapAttrs (_: value: recurseIntoAttrs value) {
  de-ud-large = stickerModel {
    modelName = "de-ud-large";
    version = "20200523";
    sha256 = "1q36yc67sqm7wg7ld0nhnxgk5gzv1b5mbbpxwy2df2xm0cybm89l";
  };

  nl-ud-large = stickerModel {
    modelName = "nl-ud-large";
    version = "20200420";
    sha256 = "0gyajncfw9x0lsfvplkhfj72l0q47clrsp0x55gp368l2bqwj9z7";
  };

  nl-ud-medium = stickerModel {
    modelName = "nl-ud-medium";
    version = "20200430";
    sha256 = "0z62smmkc43yiw8fbnfqvlmk7f70qgyjrh41mj6q9y4p4bpa2igz";
  };
}
