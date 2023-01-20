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
          rev = "f6b41f43cd8c70683e7fd901c34c76250baf3ef5";
          sha256 = "sha256-+YRyShALdDQDfh5XDY36R29SzbBjlT8mCIucwJ++KrQ=";
        };
        naersk' = pkgs.callPackage naersk {};
      in {
        # For `nix build` & `nix run`:
        packages.default = naersk'.buildPackage {
          src = "${cargo_semver_checks}";
          nativeBuildInputs = with pkgs; [pkg-config perl];
          buildInputs = with pkgs; [openssl];
        };

        # For `nix develop` (optional, can be skipped):
        devShells.default = pkgs.mkShell {
          nativeBuildInputs = with pkgs; [rustc cargo];
        };
      }
    );
}
