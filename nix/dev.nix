{ bootstrap_pkgs ? import <nixpkgs> { } }:
let
  pkgs = bootstrap_pkgs; # import ./nixpkgs.nix { pkgs = bootstrap_pkgs; };
  python = pkgs.python27.override
  { packageOverrides = import ./python-package-overrides.nix;
  };
  custom-python = python.withPackages (ps:
    with ps;
    [ # tahoe-lafs

      twisted

      # checkInputs - non-recoverable from the tahoe-lafs derivation.
      # hypothesis
      # testtools
      # fixtures
      # treq

      # # Accidentally not declared by Twisted package?
      # appdirs

      # # Why is this unavailable???
      # pyhamcrest
    ]
  );
in
(custom-python.override (old: { ignoreCollisions = true; })).env
