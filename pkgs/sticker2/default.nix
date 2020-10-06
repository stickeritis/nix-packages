{ callPackage
, lib
, stdenv

, buildRustCrate
, defaultCrateOverrides
, fetchFromGitHub

# Native build inputs
, installShellFiles
, removeReferencesTo

# Build inputs
, darwin
, libtorch

# Build with HDF5 support.
, withHdf5 ? true

# Build with TensorBoard support.
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
  };
in cargo_nix.workspaceMembers.sticker2-utils.build.override {
  features = lib.optionals withHdf5 [ "load-hdf5" ]
    ++ lib.optionals withTFRecord [ "tfrecord" ];
}
