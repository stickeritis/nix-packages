{ callPackage
, lib
, stdenv

, buildRustCrate
, defaultCrateOverrides
, fetchFromGitHub

# Native build inputs
, installShellFiles
, pkgconfig
, removeReferencesTo
, symlinkJoin

# Build inputs
, curl
, darwin
, hdf5
, libtorch
, sentencepiece

, withHdf5 ? true
, withTFRecord ? true
}:

let
  sticker2_src = fetchFromGitHub {
    owner = "stickeritis";
    repo = "sticker2";
    rev = "0.5.1";
    sha256 = "0lk2c57vrav5hdlvb27lvw4ycp2wrp0zl60vbsqfldcv96ksmiks";
  };
  cargo_nix = callPackage ./Cargo.nix {
    buildRustCrate = buildRustCrate.override {
      defaultCrateOverrides = crateOverrides;
    };
  };
  crateOverrides = defaultCrateOverrides // {
    hdf5-sys = attr: {
      # Unless we use pkg-config, the hdf5-sys build script does not like
      # it if libraries and includes are in different directories.
      HDF5_DIR = symlinkJoin { name = "hdf5-join"; paths = [ hdf5.dev hdf5.out ]; };
    };

    sentencepiece-sys = attr: {
      nativeBuildInputs = [ pkgconfig ];

      buildInputs = [ sentencepiece ];
    };

    sticker2 = attr: { src = "${sticker2_src}/sticker2"; };

    sticker2-utils = attr: rec {
      pname = "sticker2";
      name = "${pname}-${attr.version}";

      src = "${sticker2_src}/sticker2-utils";

      nativeBuildInputs = [
        installShellFiles
        removeReferencesTo
      ];

      buildInputs = [ libtorch ]
        ++ stdenv.lib.optional stdenv.isDarwin darwin.Security;

      postInstall = ''
        # We do not care for sticker2-utils as a library crate. Removing
        # the library ensures that we don't get any stray references.
        rm -rf $lib/lib

        # Install shell completions
        for shell in bash fish zsh; do
          target/bin/sticker2 completions $shell > completions.$shell
        done

        installShellCompletion completions.{bash,fish,zsh}

        # libtorch' headers use the __FILE__ macro in exceptions, this
        # creates a false dependency on the libtorch dev output.
        remove-references-to -t ${libtorch.dev} $out/bin/sticker2
      '';

      disallowedReferences = [ libtorch.dev ];

      meta = with stdenv.lib; {
        description = "Neural sequence labeler";
        license = licenses.blueOak100;
        maintainers = with maintainers; [ danieldk ];
        platforms = platforms.all;
      };
    };

    torch-sys = attr: {
      buildInputs = stdenv.lib.optional stdenv.isDarwin curl;

      LIBTORCH = libtorch.dev;
    };
  };
in cargo_nix.workspaceMembers.sticker2-utils.build.override {
  features = lib.optionals withHdf5 [ "load-hdf5" ]
    ++ lib.optionals withTFRecord [ "tfrecord" ];
}
