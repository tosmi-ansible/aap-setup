{
  description = "Ansible Lab Environment";
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        # overlay-unstable = final: prev: {
        # unstable = import nixpkgs-unstable {
        #   inherit system;
        #   config.allowUnfree = true;
        # };
      in
      {
        devShells.default = pkgs.mkShell {
          packages = [
            pkgs.pre-commit
            pkgs.gitleaks

            pkgs.ansible
            pkgs.ansible-lint
            pkgs.ansible-navigator
            pkgs.ansible-builder
            pkgs.glibcLocales
            pkgs.yamllint
            pkgs.kubevirt
            pkgs.python312Packages.kubernetes
          ];
        };
      });
}
