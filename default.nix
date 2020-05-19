{ pkgs ? import (import ./nix/sources.nix).nixpkgs {} }:

let
  sources = import ./nix/sources.nix;
  danieldk = pkgs.callPackage sources.danieldk {};
in rec {
  # The `lib`, `modules`, and `overlay` names are special
  lib = import ./lib { inherit pkgs; };
  modules = import ./modules;
  overlays = import ./overlays;

  # Pin Tensorflow to our preferred version.
  libtensorflow = with pkgs; callPackage ./pkgs/libtensorflow {
    inherit (linuxPackages) nvidia_x11;
    cudatoolkit = cudatoolkit_10_1;
    cudnn = cudnn_cudatoolkit_10_1;
  };

  python3Packages = pkgs.recurseIntoAttrs (
    pkgs.python3Packages.callPackage ./pkgs/python-modules {}
  );

  sentencepiece = pkgs.callPackage ./pkgs/sentencepiece {};

  sticker = pkgs.callPackage ./pkgs/sticker {
    inherit libtensorflow;
  };

  sticker_models = pkgs.recurseIntoAttrs (
    pkgs.callPackage ./pkgs/sticker_models {
      inherit sticker;
    }
  );

  sticker_pipelines = pkgs.recurseIntoAttrs (
    pkgs.callPackage ./pkgs/sticker_pipelines {
      inherit sticker_models sticker;
    }
  );

  sticker2 = pkgs.callPackage ./pkgs/sticker2 {
    libtorch = danieldk.libtorch.v1_5_0;

    sentencepiece = sentencepiece.override {
      withGPerfTools = false;
    };
  };

  sticker2_models = pkgs.recurseIntoAttrs (
    pkgs.callPackage ./pkgs/sticker2_models {
      sticker2 = sticker2.override { withHdf5 = false; };
    }
  );
}
