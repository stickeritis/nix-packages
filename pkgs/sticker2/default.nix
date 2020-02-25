{ callPackage
, lib
, gcc8Stdenv
, stdenv

, buildRustCrate
, defaultCrateOverrides
, fetchFromGitHub

# Native build inputs
, installShellFiles ? null # Available in 19.09 and later.
, pkgconfig
, symlinkJoin

# Build inputs
, curl
, darwin
, hdf5
, libtorch
, sentencepiece

, withHdf5 ? true
}:

let
  sticker_src = fetchFromGitHub {
    owner = "stickeritis";
    repo = "sticker2";
    rev = "0.2.1";
    sha256 = "18kraav933nbr70jzcr34g4arkh7qxsb4zfxjpaqy02xwaqnxykl";
  };
  cargo_nix = callPackage ./Cargo.nix {
    buildRustCrate = buildRustCrate.override {
      # Ensure that we use stdenv provided as an argument.
      inherit stdenv;

      defaultCrateOverrides = crateOverrides;
    };
  };
  # PyTorch 1.4.0 headers are not compatible with gcc 9. Remove with
  # the next PyTorch release.
  compatStdenv = if stdenv.cc.isGNU then gcc8Stdenv else stdenv;
  crateOverrides = defaultCrateOverrides // {
    hdf5-sys = attr: {
      # Unless we use pkg-config, the hdf5-sys build script does not like
      # it if libraries and includes are in different directories.
      HDF5_DIR = symlinkJoin { name = "hdf5-join"; paths = [ hdf5.dev hdf5.out ]; };
    };

    sentencepiece-sys = attr: {
      nativeBuildInputs = [ pkgconfig ];

      buildInputs = [ (sentencepiece.override (attrs: { stdenv = compatStdenv; })) ];
    };

    sticker2 = attr: { src = "${sticker_src}/sticker2"; };

    sticker2-utils = attr: rec {
      pname = "sticker2";
      name = "${pname}-${attr.version}";

      src = "${sticker_src}/sticker2-utils";

      nativeBuildInputs = lib.optional (!isNull installShellFiles) installShellFiles;

      buildInputs = stdenv.lib.optional stdenv.isDarwin darwin.Security;

      postBuild = ''
        for shell in bash fish zsh; do
          target/bin/sticker2 completions $shell > completions.$shell
        done
      '';

      postInstall = ''
        # We do not care for sticker2-utils as a library crate. Removing
        # the library reduces the number of dependencies.
        rm -rf $out/lib

        rm $out/bin/*.d
      '' + lib.optionalString (!isNull installShellFiles) ''
        # Install shell completions
        installShellCompletion completions.{bash,fish,zsh}
      '';

      meta = with stdenv.lib; {
        description = "Neural sequence labeler";
        license = licenses.asl20;
        maintainers = with maintainers; [ danieldk ];
        platforms = platforms.all;
      };
    };

    torch-sys = attr: {
      # Only necessary as long as sticker2 uses a git version of tch.
      src = "${attr.src}/torch-sys";


      buildInputs = stdenv.lib.optional stdenv.isDarwin curl;

      LIBTORCH = libtorch;
    };
  };
in cargo_nix.workspaceMembers.sticker2-utils.build.override {
  features = lib.optional withHdf5 "load-hdf5";
}
