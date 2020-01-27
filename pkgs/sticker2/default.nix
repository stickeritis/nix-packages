{ callPackage
, lib
, stdenv

, buildRustCrate
, defaultCrateOverrides
, fetchFromGitHub

# Native build inputs
, installShellFiles ? null # Available in 19.09 and later.
, symlinkJoin

# Build inputs
, curl
, darwin
, hdf5
, libtorch
}:

let
  sticker_src = fetchFromGitHub {
    owner = "stickeritis";
    repo = "sticker2";
    rev = "0.1.1";
    sha256 = "1xwccs50glzgj1zbl0icajq7p06gyr04zcxabsqnjxas6bi0xncp";
  };
  cargo_nix = callPackage ./Cargo.nix {
    buildRustCrate = buildRustCrate.override {
      # Ensure that we use stdenv provided as an argument.
      inherit stdenv;

      defaultCrateOverrides = crateOverrides;
    };
  };
  crateOverrides = defaultCrateOverrides // {
    hdf5-sys = attr: {
      # Unless we use pkg-config, the hdf5-sys build script does not like
      # it if libraries and includes are in different directories.
      HDF5_DIR = symlinkJoin { name = "hdf5-join"; paths = [ hdf5.dev hdf5.out ]; };
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
      buildInputs = stdenv.lib.optional stdenv.isDarwin curl;

      LIBTORCH = libtorch;
    };
  };
in cargo_nix.workspaceMembers.sticker2-utils.build
