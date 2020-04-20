{ lib, recurseIntoAttrs, stdenvNoCC, fetchurl, dockerTools, makeWrapper, sticker2 }:

let
  stickerModel = import ./model.nix {
    inherit lib stdenvNoCC fetchurl dockerTools makeWrapper sticker2;
  };
in lib.mapAttrs (_: value: recurseIntoAttrs value) {
  nl-ud-large = stickerModel {
    modelName = "nl-ud-large";
    version = "20200420";
    sha256 = "0gyajncfw9x0lsfvplkhfj72l0q47clrsp0x55gp368l2bqwj9z7";
  };
}
