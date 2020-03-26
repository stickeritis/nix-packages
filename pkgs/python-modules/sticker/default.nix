{ pkgs
, stdenv
, callPackage
, defaultCrateOverrides
, fetchFromGitHub

  # Native build inputs
, maturin
, pip

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
  version = "0.2.0";
  name = "${python.libPrefix}-${pname}-${version}";

  src = fetchFromGitHub {
    owner = "stickeritis";
    repo = "sticker-python";
    rev = version;
    sha256 = "14jmy7fjnr6456wpbipckgvi8c256njnm2bmqz3dzg22ly3d9nd1";
  };

  cargoSha256 = "1sh6fqbbmzjavmxm4pj7d8znxqxgjsj0iggjh3cqgx1qfby6y12f";

  nativeBuildInputs = [ maturin pkgs.pkgconfig pip ];

  buildInputs = [ pkgs.openssl python libtensorflow-bin ] ++
    stdenv.lib.optionals stdenv.isDarwin [ pkgs.curl darwin.Security ];

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
