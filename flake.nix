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
    let
      specialArgs.lib = nixpkgs.lib.extend (self: _: (import ./lib { inherit inputs self; }));
    in
    flake-parts.lib.mkFlake { inherit inputs specialArgs; } {
      imports = [
        ./homes
        ./hosts
        ./lib
        ./modules
        ./nix-unit
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

      perSystem =
        {
          config,
          self',
          inputs',
          pkgs,
          system,
          lib,
          ...
        }:
        let
          inherit (builtins) attrValues elem;
          inherit (pkgs) mkShell;
          inherit (lib) getExe filterAttrs getName;

          additionalPackages =
            config.packages
            |> filterAttrs (
              key: value:
              (elem key [
                "dotfiles-check"
                "mknix"
                "repl"
                "vm"
              ])
            )
            |> attrValues;

          onefetch = getExe pkgs.onefetch;
        in
        {
          _module.args.pkgs = import self.inputs.nixpkgs {
            inherit system;
            config.allowUnfreePredicate =
              pkg:
              elem (getName pkg) [
              ];
          };

          # NOTE: This sets the formatter
          # treefmt = {
          #   programs = {
          #     nixfmt.enable = true;
          #     shellcheck.enable = true;
          #   };
          #   settings.formatter.shellcheck.excludes = [ "**/.envrc" ];
          # };

          pre-commit.settings.hooks = {
            nixfmt-rfc-style.enable = true;
            shellcheck.enable = true;
            # pre-commit-ensure-sops.enable = true;
            # ripsecrets.enable = true;
            # trufflehog.enable = true;

            gitleaks = {
              enable = true;

              name = "Detect hardcoded secrets";
              description = "Detect hardcoded secrets using Gitleaks";
              entry = "gitleaks git --pre-commit --redact --staged --verbose";
              language = "golang";
              pass_filenames = false;
            };

            gitleaks-docker = {
              enable = false;

              name = "Detect hardcoded secrets";
              description = "Detect hardcoded secrets using Gitleaks";
              entry = "gitleaks git --pre-commit --redact --staged --verbose";
              language = "docker_image";
              pass_filenames = false;
            };

            gitleaks-system = {
              enable = true;

              name = "Detect hardcoded secrets";
              description = "Detect hardcoded secrets using Gitleaks";
              entry = "gitleaks git --pre-commit --redact --staged --verbose";
              language = "system";
              pass_filenames = false;
            };

          };

          devShells.default = mkShell {
            name = "dotfiles.nix";

            packages = [
              pkgs.age
              pkgs.git
              pkgs.git-crypt
              pkgs.gitleaks
              pkgs.git-secrets
              # pkgs.guestfs-tools
              pkgs.nh
              pkgs.nix-index
              pkgs.nixos-rebuild
              pkgs.ripsecrets
              pkgs.sops
              pkgs.ssh-to-age
              pkgs.tokei
              pkgs.trufflehog
            ]
            ++ [
              inputs'.nixos-anywhere.packages.nixos-anywhere
              inputs'.home-manager.packages.home-manager
            ]
            ++ additionalPackages
            ++ config.pre-commit.settings.enabledPackages
            ++ [ nix-unit.packages.${system}.nix-unit ];

            env = {
              NIX_SSHOPTS = "-o RequestTTY=force";
            };

            shellHook = ''
              ${config.pre-commit.installationScript}
              ${onefetch} --no-bots
            '';
          };

          nix-unit = {
            inputs = {
              # NOTE: a `nixpkgs-lib` follows rule is currently required
              inherit (inputs) nixpkgs flake-parts nix-unit;
            };
          };
        };
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

    hyprshell = {
      url = "github:H3rmt/hyprshell?ref=hyprshell-release";
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

  };
}
