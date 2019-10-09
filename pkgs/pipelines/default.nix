{ callPackage, sticker, models }:

rec {
  createPipeline = callPackage ./pipeline.nix {
    inherit sticker;
  };

  de-ud = createPipeline {
    name = "de-ud";
    version = "20191002";
    models = with models; [
      de-pos-ud
      de-topo-ud-small
      de-deps-ud-large
      de-ner-ud-small
    ];
  };

  nl-ud = createPipeline {
    name = "nl-ud";
    version = "20191003";
    models = with models; [
      nl-pos-ud
      nl-deps-ud-large
      nl-ner-ud-small
    ];
  };
}
