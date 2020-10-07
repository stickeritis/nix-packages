{ callPackage
, lib
, stdenv

, defaultCrateOverrides
, fetchFromGitHub

# Native build inputs
, installShellFiles ? null # Available in 19.09 and later.
, pkgconfig

# Build inputs
, curl
, darwin
, libtensorflow }:

let
  sticker_src = fetchFromGitHub {
    owner = "danieldk";
    repo = "sticker";
    rev = "0.11.1";
    sha256 = "0jnlxf25db0ggi81ykbz9y5dd4kcc3ffnrva8p0z98aqvq4jl815";
  };
  cargo_nix = callPackage ./Cargo.nix {
    defaultCrateOverrides = crateOverrides;
  };
  crateOverrides = defaultCrateOverrides // {
    sticker = attr: { src = "${sticker_src}/sticker"; };

    sticker-tf-proto = attr: { src = "${sticker_src}/sticker-tf-proto"; };

    sticker-utils = attr: rec {
      pname = "sticker";
      name = "${pname}-${attr.version}";

      src = "${sticker_src}/sticker-utils";

      nativeBuildInputs = lib.optional (!isNull installShellFiles) installShellFiles;

      buildInputs = stdenv.lib.optional stdenv.isDarwin darwin.Security;

      postBuild = ''
        for shell in bash fish zsh; do
          target/bin/sticker completions $shell > completions.$shell
        done
      '';

      postInstall = ''
        # We do not care for sticker-utils as a library crate. Removing
        # the library reduces the number of dependencies.
        rm -rf $out/lib
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
  };
in cargo_nix.workspaceMembers.sticker-utils.build
