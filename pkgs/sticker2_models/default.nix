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

  nl-ud-huge = stickerModel {
    modelName = "nl-ud-huge";
    version = "20200310";
    sha256 = "1gh8sy3wwmfbcs3brliq75vnq11547ffbl8m3fkp8a7jnqznbzcv";
  };

  nl-ud-large = stickerModel {
    modelName = "nl-ud-large";
    version = "20200220";
    sha256 = "0ahqwkhc161i8vzbfxq2lvrdzv2rmp44gjyfg5vnpwjw00i0xk8q";
  };
}
