{ lib, recurseIntoAttrs, stdenvNoCC, fetchurl, makeWrapper, sticker }:

let
  stickerModel = import ./model.nix;

  # Embeddings fetcher, uses the sticker-models repository.
  fetchEmbeddings = { name, sha256 }: {
    embeds = fetchurl {
      inherit sha256;
      url = "https://github.com/stickeritis/sticker-models/releases/download/${name}/${name}.fifu";
    };

    filename = "${name}.fifu";
  };

  deUdSttsTagEmbeds = fetchEmbeddings {
    name = "de-structgram-tags-ud-20190629";
    sha256 = "1dglh4y04v9nagxa7rjlh4381652gmv53v64asin09x69wa3hi2j";
  };
  deWordEmbeds = fetchEmbeddings {
    name = "de-structgram-20190426-opq";
    sha256 = "0b75bpsrfxh173ssa91pql3xmvd7x9f2qwc6rv27jj6pxlhayfql";
  };
in lib.mapAttrs (_: value: recurseIntoAttrs value) {
  de-deps-ud-large = stickerModel {
    inherit stdenvNoCC fetchurl makeWrapper sticker;

    modelName = "de-deps-ud-large";
    version = "20190926";
    sha256 = "15jg0vkpd55833qbykzg1pp7kh34sm59vrvg07rz3cjg9cks8nw2";

    wordEmbeds = deWordEmbeds;
    tagEmbeds = deUdSttsTagEmbeds;
  };

  de-deps-ud-small = stickerModel {
    inherit stdenvNoCC fetchurl makeWrapper sticker;

    modelName = "de-deps-ud-small";
    version = "20190923";
    sha256 = "1q405xmdlvwndf8y8pij89qjkd5i43x35vwfpijzq729s7ry3mpc";

    wordEmbeds = deWordEmbeds;
    tagEmbeds = deUdSttsTagEmbeds;
  };

  de-ner-ud-small = stickerModel {
    inherit stdenvNoCC fetchurl makeWrapper sticker;

    modelName = "de-ner-ud-small";
    version = "20190928";
    sha256 = "01bay1bxhap9mmwmjgfr17z1w8f05h3d16czf9vl3b3r3a2b0q23";

    wordEmbeds = deWordEmbeds;
    tagEmbeds = deUdSttsTagEmbeds;
  };

  de-pos-ud = stickerModel {
    inherit stdenvNoCC fetchurl makeWrapper sticker;

    modelName = "de-pos-ud";
    version = "20190821";
    sha256 = "163himdn8l1ds6znf1girx0hbplbc8i9z9lmqdwvxsj9d9338svv";

    wordEmbeds = deWordEmbeds;
  };
}
