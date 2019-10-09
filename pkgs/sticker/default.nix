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
  sticker_src = fetchFromGitHub {
    owner = "danieldk";
    repo = "sticker";
    rev = "0.9.0";
    sha256 = "0lxpq2piq98vxis6wjw5882zx2y6wqvbchngzjsvvgz3n212zprd";
  };
  cargo_nix = callPackage ./Cargo.nix {};
in cargo_nix.workspaceMembers.sticker-utils.build.override {
  crateOverrides = defaultCrateOverrides // {
    sticker = attr: { src = "${sticker_src}/sticker"; };

    sticker-tf-proto = attr: { src = "${sticker_src}/sticker-tf-proto"; };

    sticker-utils = attr: rec {
      pname = "sticker";
      name = "${pname}-${attr.version}";

      src = "${sticker_src}/sticker-utils";

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
