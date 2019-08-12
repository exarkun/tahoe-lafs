{ bootstrap_pkgs ? import <nixpkgs> { } }:
let
  pkgs = import ./nixpkgs.nix { pkgs = bootstrap_pkgs; };
  tahoe-lafs-lib = pkgs.python27Packages.callPackage ./tahoe-lafs.nix { };
  custom-python = pkgs.python27.withPackages (ps:
    with pkgs.python27.pkgs;
    [ tahoe-lafs-lib

      # checkInputs - non-recoverable from the tahoe-lafs derivation.
      hypothesis
      testtools
      fixtures
      treq

      # Accidentally not declared by Twisted package?
      appdirs

      # Why is this unavailable???
      pyhamcrest
    ]
  );
in
(custom-python.override (old: { ignoreCollisions = true; })).env
