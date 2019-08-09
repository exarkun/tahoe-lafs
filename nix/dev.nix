{ pkgs ? import <nixpkgs> { overlays = [ (import ./overlays.nix) ]; } }:
let
  tahoe-lafs-lib = pkgs.python27Packages.callPackage ./tahoe-lafs.nix { };
in
(pkgs.python27.buildEnv.override {
  extraLibs = [ tahoe-lafs-lib ];
  ignoreCollisions = true;
}).env
