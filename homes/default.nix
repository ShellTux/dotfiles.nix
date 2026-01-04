{
  self,
  inputs,
  config,
  ...
}:
let
  inherit (inputs) nixpkgs;
  inherit (inputs.home-manager.lib) homeManagerConfiguration;
  inherit (config.flake) homeManagerModules packages;

  flake-lib = import ../lib.nix { inherit inputs self; };

  mkHome =
    {
      name,
      system,
      extraModules ? [ homeManagerModules.default ],
    }:
    homeManagerConfiguration {
      pkgs = import nixpkgs {
        inherit system;
        overlays = [ (import ../overlays.nix { inherit inputs; }) ];
      };

      modules = extraModules ++ [
        {
          nixpkgs = {
            overlays = [ (import ../overlays.nix { inherit inputs; }) ];
            config.packageOverrides = pkgs: {
              small = import inputs.nixpkgs-small { inherit system; };
              stable = import inputs.nixpkgs-stable { inherit system; };
            };
          };
        }
        ./${name}
      ];

      extraSpecialArgs = {
        inherit
          inputs
          self
          system
          flake-lib
          ;

        flake-pkgs = packages.${system};
      };
    };
in
{
  flake.homeConfigurations = {
    luisgois = mkHome {
      name = "luisgois";
      system = "x86_64-linux";
    };

    dev = mkHome {
      name = "dev";
      system = "x86_64-linux";
    };

    streamer = mkHome {
      name = "streamer";
      system = "x86_64-linux";
    };

    # For Unit testing purposes
    test = mkHome {
      name = "test";
      system = "x86_64-linux";
    };
  };
}
