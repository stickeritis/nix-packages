{ stdenv
, callPackage
, defaultCrateOverrides
, fetchFromGitHub

# Native build inputs
, pkgconfig

# Build inputs
, curl
, darwin
, libtensorflow }:

let
  src = fetchFromGitHub {
    owner = "danieldk";
    repo = "sticker";
    rev = "0.6.1";
    sha256 = "02s2nh1vvr8cdpr8a9v6203nwjjylcywa23q0zn52lqr5la3vgzl";
  };
  cargo_nix = callPackage ./sticker.nix {};
in cargo_nix.workspaceMembers.sticker-utils.build.override {
  crateOverrides = defaultCrateOverrides // {
    sticker = attr: { src = "${src}/sticker"; };

    sticker-tf-proto = attr: { src = "${src}/sticker-tf-proto"; };

    sticker-utils = attr: {
      src = "${src}/sticker-utils";

      buildInputs = stdenv.lib.optional stdenv.isDarwin darwin.Security;

      postInstall = ''
        # We do not care for sticker-utils as a library crate. Removing
        # the library reduces the number of dependencies.
        rm -rf $out/lib

        rm $out/bin/*.d
      '';

      meta = with stdenv.lib; {
        description = "Neural sequence labeler";
        license = licenses.asl20;
        maintainers = with maintainers; [ danieldk ];
        platforms = platforms.all;
      };
    };

    tensorflow-sys = attrs: {
      nativeBuildInputs = [ pkgconfig ];

      buildInputs = [ libtensorflow ] ++
        stdenv.lib.optional stdenv.isDarwin curl;
    };
  };
}
