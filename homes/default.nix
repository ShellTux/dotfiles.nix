{
  self,
  inputs,
  config,
  lib,
  withSystem,
  ...
}:
let
  inherit (lib) optional;
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
    let
      overlays = [ self.overlays.default ] ++ optional (self.overlays ? ${name}) self.overlays.${name};
    in
    withSystem system (
      { inputs', self', ... }:
      homeManagerConfiguration {
        pkgs = import nixpkgs { inherit system; };

        modules = extraModules ++ [
          {
            nixpkgs = {
              inherit overlays;

              config.packageOverrides = pkgs: {
                small = import inputs.nixpkgs-small { inherit system overlays; };
                stable = import inputs.nixpkgs-stable { inherit system overlays; };
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
