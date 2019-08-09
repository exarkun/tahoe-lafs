{ pkgs ? import <nixpkgs> { overlays = [ (import ./overlays.nix) ]; } }:
let
  tahoe-lafs-app = pkgs.python27Packages.callPackage ./tahoe-lafs.nix { };
  tahoe-lafs-lib = pkgs.python27Packages.toPythonModule tahoe-lafs-app;
in
(pkgs.python27.buildEnv.override {
  extraLibs = [ tahoe-lafs-lib ];
  ignoreCollisions = true;
}).env
