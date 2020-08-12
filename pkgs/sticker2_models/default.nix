{ lib, recurseIntoAttrs, stdenvNoCC, fetchurl, dockerTools, makeWrapper, sticker2 }:

let
  stickerModel = import ./model.nix {
    inherit lib stdenvNoCC fetchurl dockerTools makeWrapper sticker2;
  };
in lib.mapAttrs (_: value: recurseIntoAttrs value) {
  de-ud-huge = stickerModel {
    modelName = "de-ud-huge";
    version = "20200812";
    sha256 = "1gzpgzq1dxcs5vcxhx72v0dc22wxk9ja2sqgjv15yag42lprj9rn";
  };

  de-ud-large = stickerModel {
    modelName = "de-ud-large";
    version = "20200812";
    sha256 = "086xl9m8hh5brqfriy86zqir6grclsdf0n9apna11bahc0vi4h9g";
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
