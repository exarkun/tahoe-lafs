{ bootstrap_pkgs ? import <nixpkgs> { } }:
let
  pkgs = import ./nixpkgs.nix { pkgs = bootstrap_pkgs; };
  tahoe-lafs-lib = pkgs.python27Packages.callPackage ./tahoe-lafs.nix { };
in
(pkgs.python27.buildEnv.override {
  extraLibs = [ tahoe-lafs-lib ];
  ignoreCollisions = true;
}).env
