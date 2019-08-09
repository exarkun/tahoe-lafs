{ pkgs ? import <nixpkgs> { } }:
pkgs.stdenv.mkDerivation {
  name = "python-dev-environment";

  # ValueError: ZIP does not support timestamps before 1980
  SOURCE_DATE_EPOCH = 1559322353;

  # Python bytecode files are such a pain.
  PYTHONDONTWRITEBYTECODE = 1;

  buildInputs = [
    pkgs.pythonPackages.virtualenv
    pkgs.pythonPackages.pyflakes
    # python-cryptography
    pkgs.openssl
    pkgs.daemonize
  ];

}
