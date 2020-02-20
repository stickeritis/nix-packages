{ lib, recurseIntoAttrs, stdenvNoCC, fetchurl, dockerTools, makeWrapper, sticker2 }:

let
  stickerModel = import ./model.nix;
in lib.mapAttrs (_: value: recurseIntoAttrs value) {
  nl-ud-large = stickerModel {
    inherit lib stdenvNoCC fetchurl dockerTools makeWrapper sticker2;

    modelName = "nl-ud-large";
    version = "20200128";
    sha256 = "0l8s2xy397ps1g4kqppcq57ahqnkc9bszm9wn8y3gisrblzl6fap";
  };

  nl-ud-medium = stickerModel {
    inherit lib stdenvNoCC fetchurl dockerTools makeWrapper sticker2;

    modelName = "nl-ud-medium";
    version = "20200129";
    sha256 = "08ny3i2aspabnmnj9wgmpyarkad08ppm907rzz7j578w1ij8zwhp";
  };

  nl-ud-small = stickerModel {
    inherit lib stdenvNoCC fetchurl dockerTools makeWrapper sticker2;

    modelName = "nl-ud-small";
    version = "20200201";
    sha256 = "032mjp6k1dwks21x16kdzpcsm5vh97py2ffai3dnwfr047a5p934";
  };
}