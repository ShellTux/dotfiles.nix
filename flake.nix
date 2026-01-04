{
  description = "Dotfiles managed by Nix, NixOS and HomeManager";

  nixConfig.commit-lockfile-summary = "chore(flake.lock): update inputs";

  outputs =
    inputs@{
      self,
      flake-parts,
      git-hooks-nix,
      home-manager,
      nixos-anywhere,
      nixpkgs,
      nix-unit,
      treefmt-nix,
      ...
    }:
    # let
    #   specialArgs.lib = nixpkgs.lib.extend (self: _: (import ./lib { inherit inputs self; }));
    # in
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        ./flake
      ]
      ++ [
        ./homes
        ./hosts
        ./lib
        ./modules
        ./pkgs
      ]
      ++ [
        nix-unit.modules.flake.default
        treefmt-nix.flakeModule
        git-hooks-nix.flakeModule
      ];

      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ];
    };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.05";
    nixpkgs-small.url = "github:NixOS/nixpkgs/nixos-unstable-small"; # moves faster, has less packages

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    flake-utils.url = "github:numtide/flake-utils";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-topology.url = "github:oddlama/nix-topology";

    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    git-hooks-nix.url = "github:cachix/git-hooks.nix";

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-unit = {
      url = "github:nix-community/nix-unit";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-parts.follows = "flake-parts";
      };
    };

    treefmt-nix.url = "github:numtide/treefmt-nix";

    stylix = {
      url = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-anywhere = {
      url = "github:nix-community/nixos-anywhere";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    dwl = {
      url = "github:ShellTux/dwl";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    slstatus = {
      url = "github:ShellTux/slstatus";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    easyeffects-presets = {
      url = "github:Digitalone1/EasyEffects-Presets";
      flake = false;
    };

    easyeffect-preset = {
      url = "github:EvoXCX/EasyEffect-Preset";
      flake = false;
    };

    pyprland.url = "github:hyprland-community/pyprland";

  };
}
