{ pkgs ? import (import ./nix/sources.nix).nixpkgs {} }:

let
  sources = import ./nix/sources.nix;
  danieldk = pkgs.callPackage sources.danieldk {};
in rec {
  # The `lib`, `modules`, and `overlay` names are special
  lib = import ./lib { inherit pkgs; };
  modules = import ./modules;
  overlays = import ./overlays;

  dockerImages = pkgs.callPackage ./docker-images {
    inherit models pipelines;
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

  pipelines = pkgs.recurseIntoAttrs (
    pkgs.callPackage ./pkgs/pipelines {
      inherit models sticker;
    }
  );

  python3Packages = pkgs.recurseIntoAttrs (
    pkgs.python3Packages.callPackage ./pkgs/python-modules {}
  );

  sticker = pkgs.callPackage ./pkgs/sticker {
    libtensorflow = libtensorflow_1_14_0;
  };

  sticker2 = let
    # PyTorch 1.4.0 does not work with gcc 9.x. The stdenv ovveride
    # should be removed after the next PyTorch dot release.
    #
    # https://github.com/pytorch/pytorch/issues/32277
    stdenv = if pkgs.stdenv.cc.isGNU then pkgs.gcc8Stdenv else pkgs.stdenv;
  in pkgs.callPackage ./pkgs/sticker2 {
    inherit stdenv;

    libtorch = danieldk.libtorch.v1_4_0.override { inherit stdenv; };
  };


  sticker2_models = pkgs.recurseIntoAttrs (
    pkgs.callPackage ./pkgs/sticker2_models {
      inherit sticker2;
    }
  );
}
