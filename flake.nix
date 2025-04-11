{
  description = "Dotfiles managed by Nix, NixOS and HomeManager";

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      flake = {
        # Put your original flake attributes here.
      };
      systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin" ];
      perSystem = { config, self', inputs', pkgs, system, ... }: let
        inherit (pkgs.lib) getExe;

        onefetch = getExe pkgs.onefetch;
      in {
        # Per-system attributes can be defined here. The self' and inputs'
        # module parameters provide easy access to attributes of the same
        # system.

        # Equivalent to  inputs'.nixpkgs.legacyPackages.hello;
        packages.default = pkgs.hello;
        devShells.default = pkgs.mkShell {
          shellHook = ''
            ${onefetch} --no-bots
          '';
        };
      };
    };

  inputs = {
    # We build against NixOS unstable, because stable takes way too long to get things into
    # more versions with or without pinned branches can be added if deemed necessary
    # stable? Never heard of her.
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.11";
    nixpkgs-small.url = "github:NixOS/nixpkgs/nixos-unstable-small"; # moves faster, has less packages

    # Sometimes nixpkgs breaks something I need, pin a working commit when that occurs
    # nixpkgs-pinned.url = "github:NixOS/nixpkgs/b610c60e23e0583cdc1997c54badfd32592d3d3e";

    # Powered by
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    # Home Manager
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Ever wanted nix error messages to be even more cryptic?
    # Try flake-utils today! (Devs I beg you please stop)
    flake-utils.url = "github:numtide/flake-utils";

    # This exists, I guess
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
  };

}
