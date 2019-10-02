{ pkgs
, stdenv
, callPackage
, defaultCrateOverrides
, fetchFromGitHub

  # Native build inputs
, maturin

  # Build inputs
, darwin
, libtensorflow-bin
, openssl
, python

  # Check inputs
, pytest
}:

let
  rustPlatform = callPackage ./rust-platform-nightly.nix {};
in (rustPlatform "2019-07-30").buildRustPackage rec {
  pname = "sticker";
  version = "0.1.0";
  name = "${python.libPrefix}-${pname}-${version}";

  src = fetchFromGitHub {
    owner = "stickeritis";
    repo = "sticker-python";
    rev = version;
    sha256 = "1ix90xhk4s2z1xc6mvwvqmghhwdphgxk2yyq2kgdc1lxhwmzc9sc";
  };

  cargoSha256 = "1fzixrwxdg7ni49wwqcljgigr7xbspl5xmwbsks68cviv4ci7589";

  nativeBuildInputs = [ maturin pkgs.pkgconfig ];

  buildInputs = [ pkgs.openssl python libtensorflow-bin ] ++ stdenv.lib.optional stdenv.isDarwin darwin.Security;

  installCheckInputs = [ pytest ];

  doCheck = false;

  doInstallCheck = true;

  buildPhase = ''
    runHook preBuild

    maturin build --release --manylinux off

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    ${python.pythonForBuild.pkgs.bootstrapped-pip}/bin/pip install \
      target/wheels/*.whl --no-index --prefix=$out --no-cache --build tmpbuild

    runHook postInstall
  '';

  installCheckPhase = ''
    PYTHONPATH="$out/${python.sitePackages}:$PYTHONPATH" pytest
  '';

  meta = with stdenv.lib; {
    description = "Python module for the sticker sequence labeler";
    license = licenses.asl20;
    maintainers = with maintainers; [ danieldk ];
    platforms = platforms.all;
  };
}
