{
  description = "iroh-ssh flake build";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    rust-overlay.url = "github:oxalica/rust-overlay";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, rust-overlay, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        overlays = [ (import rust-overlay) ];
        pkgs = import nixpkgs { inherit system overlays; };

        # Pin the specific toolchain version
        rustToolchain = pkgs.rust-bin.stable."1.93.0".default;

        # Build a custom rustPlatform using that toolchain
        customRustPlatform = pkgs.makeRustPlatform {
          cargo = rustToolchain;
          rustc = rustToolchain;
        };
      in
      {
        packages.default = pkgs.callPackage ./package.nix {
          # Overwrite the default rustPlatform with our pinned version
          rustPlatform = customRustPlatform;
        };
      }
    );
}
