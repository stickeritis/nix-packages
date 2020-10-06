{ pkgs ? import (import nix/sources.nix).nixpkgs {} }:

let
  sources = import nix/sources.nix;
  generateImages = import nixos/generate-images.nix {
    inherit (sources) nixpkgs nixos-generators;
  };
in rec {
  # The `lib`, `modules`, and `overlay` names are special
  lib = import ./lib { inherit pkgs; };
  modules = import ./modules;
  overlays = import ./overlays;

  defaultCrateOverrides = pkgs.callPackage build-support/crate-overrides.nix {
    libtorch = pkgs.libtorch-bin;
  };

  # Pin Tensorflow to our preferred version.
  libtensorflow = with pkgs; callPackage ./pkgs/libtensorflow {
    inherit (linuxPackages) nvidia_x11;
    cudatoolkit = cudatoolkit_10_1;
    cudnn = cudnn_cudatoolkit_10_1;
  };

  python3Packages = pkgs.recurseIntoAttrs (
    pkgs.python3Packages.callPackage ./pkgs/python-modules {}
  );

  sticker = pkgs.callPackage ./pkgs/sticker {
    inherit libtensorflow;
  };

  sticker_models = pkgs.recurseIntoAttrs (
    pkgs.callPackage ./pkgs/sticker_models {
      inherit generateImages sticker;
    }
  );

  sticker_pipelines = pkgs.recurseIntoAttrs (
    pkgs.callPackage ./pkgs/sticker_pipelines {
      inherit sticker_models sticker;
    }
  );

  sticker2 = pkgs.callPackage ./pkgs/sticker2 {
    inherit defaultCrateOverrides;
    libtorch = pkgs.libtorch-bin;
  };

  sticker2_models = pkgs.recurseIntoAttrs (
    pkgs.callPackage ./pkgs/sticker2_models {
      inherit generateImages;
      sticker2 = sticker2.override {
        withHdf5 = false;
        withTFRecord = false;
      };
    }
  );
}
