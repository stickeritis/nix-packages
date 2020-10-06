{ callPackage
, lib
, stdenv

, buildRustCrate
, defaultCrateOverrides
, fetchCrate

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
  cargo_nix = callPackage ./Cargo.nix {
    buildRustCrate = buildRustCrate.override {
      defaultCrateOverrides = crateOverrides;
    };
  };
  crateOverrides = defaultCrateOverrides // {
    sticker2 = attr: {
      src = fetchCrate {
        crateName = "sticker2";
        version = attr.version;
        sha256 = "0ivg1wgk700x0xgvallpr8kfyk12rvxkrryjv6z6aj58rwvp54n3";
      };
    };

    sticker2-utils = attr: rec {
      pname = "sticker2";
      name = "${pname}-${attr.version}";

      src = fetchCrate {
        crateName = "sticker2-utils";
        version = attr.version;
        sha256 = "1qh1pfd36ryws9gqli912346lbc4b2shw308bld3078kib69gasb";
      };

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
