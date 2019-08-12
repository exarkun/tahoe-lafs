{ fetchurl, lib, unzip, nettools, texinfo
, python, buildPythonPackage
, sphinx, numpy, mock, twisted, foolscap, nevow, simplejson, zfec, darcsver
, setuptoolsTrial, setuptoolsDarcs, pyasn1, zope_interface, service-identity
, pyyaml, magic-wormhole, eliot, autobahn, cryptography
, hypothesis, testtools, fixtures, treq
}:
# FAILURES: The "running build_ext" phase fails to compile Twisted
# plugins, because it tries to write them into Twisted's (immutable)
# store path. The problem appears to be non-fatal, but there's probably
# some loss of functionality because of it.

buildPythonPackage rec {
  version = "1.13.0.post";
  name = "tahoe-lafs-${version}";
  namePrefix = "";

  src = ../.;

  outputs = [ "out" "doc" "info" ];

  postPatch = ''
    sed -i "src/allmydata/util/iputil.py" \
        -es"|_linux_path = '/sbin/ifconfig'|_linux_path = '${nettools}/bin/ifconfig'|g"

    # Chroots don't have /etc/hosts and /etc/resolv.conf, so work around
    # that.
    for i in $(find src/allmydata/test -type f)
    do
      sed -i "$i" -e"s/localhost/127.0.0.1/g"
    done

    # This test is flaky.
    sed -i 's/test_stdout/skiptest_stdout/' src/allmydata/test/test_eliotutil.py
  '';

  # Remove broken and expensive tests.
  preConfigure = ''
    (
      cd src/allmydata/test

      # Buggy?
      rm cli/test_create.py test_backupdb.py

      # These require Tor and I2P.
      rm test_connections.py test_iputil.py test_hung_server.py test_i2p_provider.py test_tor_provider.py

      # Expensive
      rm test_system.py
    )
  '';

  nativeBuildInputs = [ sphinx texinfo ];

  buildInputs = [ unzip numpy mock ];

  # The `backup' command requires `sqlite3'.
  propagatedBuildInputs = [
    twisted foolscap nevow simplejson zfec darcsver
    setuptoolsTrial setuptoolsDarcs pyasn1 zope_interface
    service-identity pyyaml

    magic-wormhole eliot autobahn cryptography
  ];

  # Install the documentation.
  postInstall = ''
    (
      cd docs

      make singlehtml
      mkdir -p "$doc/share/doc/${name}"
      cp -rv _build/singlehtml/* "$doc/share/doc/${name}"

      make info
      mkdir -p "$info/share/info"
      cp -rv _build/texinfo/*.info "$info/share/info"
    )
  '';

  checkInputs = [ hypothesis testtools fixtures treq ];

  checkPhase = ''
  ${python}/bin/python -m twisted.trial -x --rterrors allmydata
  '';

  meta = {
    description = "Tahoe-LAFS, a decentralized, fault-tolerant, distributed storage system";
    longDescription = ''
      Tahoe-LAFS is a secure, decentralized, fault-tolerant filesystem.
      This filesystem is encrypted and spread over multiple peers in
      such a way that it remains available even when some of the peers
      are unavailable, malfunctioning, or malicious.
    '';
    homepage = http://tahoe-lafs.org/;
    license = [ lib.licenses.gpl2Plus /* or */ "TGPPLv1+" ];
    maintainers = with lib.maintainers; [ MostAwesomeDude ];
    platforms = lib.platforms.gnu ++ lib.platforms.linux;
  };
}
