{ lib, recurseIntoAttrs, stdenvNoCC, fetchurl, dockerTools, makeWrapper, sticker2 }:

let
  stickerModel = import ./model.nix {
    inherit lib stdenvNoCC fetchurl dockerTools makeWrapper sticker2;
  };
in lib.mapAttrs (_: value: recurseIntoAttrs value) {
  de-ud-huge = stickerModel {
    modelName = "de-ud-huge";
    version = "20200709";
    sha256 = "19iq9fzjq0xs1k7i4xhsjgx79dmjpicx36yvr35pljb236d7d77x";
  };

  de-ud-large = stickerModel {
    modelName = "de-ud-large";
    version = "20200710";
    sha256 = "16qf4qc3qwkyn2lhl4jazjk73bd2jhpr2c8dm69gnd5fzbii3r6d";
  };

  nl-ud-huge = stickerModel {
    modelName = "nl-ud-huge";
    version = "20200812";
    sha256 = "04vlkwmlx2x377r8rsy9fbyslw17z0z8h6k1ic3n7f271r66cidf";
  };

  nl-ud-large = stickerModel {
    modelName = "nl-ud-large";
    version = "20200812";
    sha256 = "19afs9sndf3az3j2j95w1s0x21b8104h0d1nzxrfdv3b0aiccq1y";
  };

  nl-ud-medium = stickerModel {
    modelName = "nl-ud-medium";
    version = "20200812";
    sha256 = "0vrm2zh53vzbvbb1jb2zrxhfv277q76zi4yv2ps34wvklxh63jpz";
  };
}
