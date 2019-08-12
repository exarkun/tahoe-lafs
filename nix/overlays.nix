self: super: rec {
  openssl = super.openssl_1_1;

  python27 = super.python27.override {
    packageOverrides = import ./python-package-overrides.nix;
  };
}
