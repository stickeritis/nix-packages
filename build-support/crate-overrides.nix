{ stdenv
, defaultCrateOverrides

# Native build inputs
, pkg-config
, removeReferencesTo
, symlinkJoin

# Build inputs
, curl
, hdf5
, libtensorflow
, libtorch
, sentencepiece
}:

defaultCrateOverrides // {
    hdf5-sys = attr: {
      # Unless we use pkg-config, the hdf5-sys build script does not like
      # it if libraries and includes are in different directories.
      HDF5_DIR = symlinkJoin { name = "hdf5-join"; paths = [ hdf5.dev hdf5.out ]; };
    };

    sentencepiece-sys = attr: {
      nativeBuildInputs = [ pkg-config ];
      buildInputs = [
        (sentencepiece.override { withGPerfTools = false; })
      ];
    };

    tensorflow-sys = attrs: {
      nativeBuildInputs = [ pkg-config ];

      buildInputs = [ libtensorflow ] ++
        stdenv.lib.optional stdenv.isDarwin curl;
    };

    torch-sys = attr: {
      buildInputs = stdenv.lib.optional stdenv.isDarwin curl;
      LIBTORCH = libtorch.dev;
    };
}
