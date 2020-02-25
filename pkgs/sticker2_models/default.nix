{ lib, recurseIntoAttrs, stdenvNoCC, fetchurl, dockerTools, makeWrapper, sticker2 }:

let
  stickerModel = import ./model.nix {
    inherit lib stdenvNoCC fetchurl dockerTools makeWrapper sticker2;
  };
in lib.mapAttrs (_: value: recurseIntoAttrs value) {
  de-ud-huge = stickerModel {
    modelName = "de-ud-huge";
    version = "20200225";
    sha256 = "0lvbkzgny2dq6jngxg35bq4rsr7jvaqpgi7ll9ddxyl06asibncd";
  };

  de-ud-large = stickerModel {
    modelName = "de-ud-large";
    version = "20200222";
    sha256 = "1czlnsxvanf69y6sxawi46q1fxs3xjf6ggvnkfr7zlgfs1i38hid";
  };

  nl-ud-large = stickerModel {
    modelName = "nl-ud-large";
    version = "20200220";
    sha256 = "0ahqwkhc161i8vzbfxq2lvrdzv2rmp44gjyfg5vnpwjw00i0xk8q";
  };

  nl-ud-medium = stickerModel {
    modelName = "nl-ud-medium";
    version = "20200129";
    sha256 = "08ny3i2aspabnmnj9wgmpyarkad08ppm907rzz7j578w1ij8zwhp";
  };

  nl-ud-small = stickerModel {
    modelName = "nl-ud-small";
    version = "20200201";
    sha256 = "032mjp6k1dwks21x16kdzpcsm5vh97py2ffai3dnwfr047a5p934";
  };
}
