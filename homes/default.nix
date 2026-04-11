{
  self,
  inputs,
  config,
  withSystem,
  ...
}:
let
  inherit (inputs) nixpkgs dev-tools;
  inherit (inputs.home-manager.lib) homeManagerConfiguration;
  inherit (config.flake) homeManagerModules;

  lib' = self.lib;

  mkHome =
    {
      name,
      system,
      extraModules ? [ homeManagerModules.default ],
    }:
    withSystem system (
      { inputs', self', ... }:
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
            inputs'
            self
            self'
            system
            lib'
            ;

          dev-tools = dev-tools.packages.${system};
        };
      }
    );

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
