{ bootstrap_pkgs ? import <nixpkgs> { } }:
let
  pkgs = import ./nixpkgs.nix { pkgs = bootstrap_pkgs; };
  python = pkgs.python27.override
  { # packageOverrides = import ./python-package-overrides.nix;
  };
  custom-python = python.withPackages (ps:
    with ps;
    [ tahoe-lafs

      # checkInputs - non-recoverable from the tahoe-lafs derivation.
      hypothesis
      testtools
      fixtures
      treq

      # Accidentally not declared by Twisted package?  And our overlay doesn't
      # help but I don't know why.  nixpkgs bug?
      appdirs
    ]
  );
in
(custom-python.override (old: { ignoreCollisions = true; })).env
