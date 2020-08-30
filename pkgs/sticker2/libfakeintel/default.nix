{ stdenv, patchelf }:

stdenv.mkDerivation {
  pname = "libfakeintel";
  version = "0.0.1";

  src = ./.;

  dontConfigure = true;

  buildPhase = ''
    cc -shared -fPIC -o libfakeintel.so fakeintel.c
  '';

  installPhase = ''
    install -Dm755 -t $out/lib libfakeintel.so
  '';

  meta = with stdenv.lib; {
    description = "Always detect an Intel CPU";
    license = licenses.cc0;
    maintainers = with maintainers; [ danieldk ];
    platforms = platforms.unix;
  };
}
