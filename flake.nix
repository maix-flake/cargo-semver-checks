{
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    naersk.url = "github:nix-community/naersk";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = {
    self,
    flake-utils,
    naersk,
    nixpkgs,
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = (import nixpkgs) {
          inherit system;
        };
        cargo_semver_checks = pkgs.fetchFromGitHub {
          owner = "obi1kenobi";
          repo = "cargo-semver-checks";
          rev = "346e10b89c1e67037c82bcdb674d30dd3b6ca86b";
          sha256 = "sha256-upGVWCK3gEPH6BZ7W410AnQPIWOCeD4sawQqPLRowfw=";
        };
        naersk' = pkgs.callPackage naersk {};
      in {
        # For `nix build` & `nix run`:
        packages.default = naersk'.buildPackage {
          src = "${cargo_semver_checks}";
          nativeBuildInputs = with pkgs; [pkg-config];
          buildInputs = with pkgs; [openssl];
        };

        # For `nix develop` (optional, can be skipped):
        devShells.default = pkgs.mkShell {
          nativeBuildInputs = with pkgs; [rustc cargo];
        };
      }
    );
}
