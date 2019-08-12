{ pkgs }:
let
  nixpkgs = fetchTarball
  { url = "https://github.com/NixOS/nixpkgs-channels/archive/56d94c8c69f8cac518027d191e2f8de678b56088.tar.gz";
    sha256 = "1c812ssgmnmh97sarmp8jcykk0g57m8rsbfjg9ql9996ig6crsmi";
  };
  args =
  { overlays = [ (import ./overlays.nix) ];
  };
in
pkgs.callPackage nixpkgs args
