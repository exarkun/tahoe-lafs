{ tahoelafs, eliot, appdirs }:
tahoelafs.overrideAttrs (old:
{ src = ../.;
  propagatedBuildInputs = old.propagatedBuildInputs ++ [ eliot ];
  doInstallCheck = false;
})
