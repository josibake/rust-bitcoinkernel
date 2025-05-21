{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
      };
    };
    bitcoin-dev.url = "github:bitcoin-dev-tools/nix-dev-shell";
  };
  outputs = { self, nixpkgs, flake-utils, rust-overlay, bitcoin-dev }:
  flake-utils.lib.eachDefaultSystem (system:
    let
      overlays = [ (import rust-overlay) ];
      pkgs = import nixpkgs { inherit system overlays; };

      rustToolchain = pkgs.pkgsBuildHost.rust-bin.fromRustupToolchainFile ./rust-toolchain.toml;
      bitcoinShell = bitcoin-dev.devShells.${system}.default;
    in
    {
      devShells.default = pkgs.mkShell {
        inputsFrom = [ bitcoinShell ];

        buildInputs = bitcoinShell.buildInputs ++ [ rustToolchain ];

        # Optional: preserve bitcoinShell.shellHook if defined
        shellHook = ''
          ${bitcoinShell.shellHook or ""}
          export LIBCLANG_PATH="${pkgs.llvmPackages_20.libclang.lib}/lib"
        '';
      };
    }
  );
}
