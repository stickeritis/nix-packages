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
    rev = "0.11.0";
    sha256 = "09dk55x38bf2j3lvsz90gpqq9f335sr6ylpk75k8m8v6lprriq5v";
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

    tensorflow-sys = attrs: {
      nativeBuildInputs = [ pkgconfig ];

      buildInputs = [ libtensorflow ] ++
        stdenv.lib.optional stdenv.isDarwin curl;
    };
  };
in cargo_nix.workspaceMembers.sticker-utils.build
