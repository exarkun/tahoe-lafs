python-self: python-super: {
  eliot = python-super.callPackage ./eliot.nix { };
  autobahn = python-super.callPackage ./autobahn.nix { };
  cryptography = python-super.callPackage ./cryptography.nix { };
  cryptography_vectors = python-super.callPackage ./cryptography_vectors.nix { };

  # upstream twisted package is missing a recently added dependency.
  twisted = python-super.twisted.overrideAttrs (old:
  { propagatedBuildInputs = old.propagatedBuildInputs ++ [ python-super.appdirs ];
    checkPhase = ''
      ${python-self.python.interpreter} -m twisted.trial twisted
    '';
  });

  tahoe-lafs = python-super.callPackage ./tahoe-lafs.nix { };
}
