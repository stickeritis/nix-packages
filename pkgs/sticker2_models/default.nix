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
}
