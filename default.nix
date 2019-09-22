{ pkgs ? import <nixpkgs> {} }:

rec {
  # The `lib`, `modules`, and `overlay` names are special
  lib = import ./lib { inherit pkgs; };
  modules = import ./modules;
  overlays = import ./overlays;

  dockerImages = pkgs.callPackage ./docker-images {
    inherit models;
  };

  # Pin Tensorflow to our preferred version.
  libtensorflow_1_14_0 = with pkgs; callPackage ./pkgs/libtensorflow {
    inherit (linuxPackages) nvidia_x11;
    cudatoolkit = cudatoolkit_10_0;
    cudnn = cudnn_cudatoolkit_10_0;
  };

  models = pkgs.recurseIntoAttrs (
    pkgs.callPackage ./pkgs/models {
      inherit sticker;
    }
  );

  sticker = pkgs.callPackage ./pkgs/sticker {
    libtensorflow = libtensorflow_1_14_0;
  };
}

