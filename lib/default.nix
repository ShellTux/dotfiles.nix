{ inputs, self, ... }:
let
  inherit (builtins) attrValues;
  inherit (inputs) nixvim nixpkgs;
  inherit (inputs.home-manager.lib) homeManagerConfiguration;
  inherit (inputs.home-manager.nixosModules) home-manager;
  inherit (inputs.nixpkgs.lib) nixosSystem;
  inherit (inputs.self) nixosModules homeManagerModules;

  profile = import "${self}/profiles";
in
{
  flake.overlays.lib = final: prev: {
    mkHost =
      {
        name,
        system,
        profiles ? [ profile.system.core ],
        extraModules ? [
          nixosModules.default
          home-manager
          nixvim.nixosModules.nixvim
          {
            home-manager = {
              useUserPackages = true;
              useGlobalPkgs = true;
              sharedModules = attrValues homeManagerModules ++ [
                nixvim.homeManagerModules.nixvim
              ];
              extraSpecialArgs = { inherit inputs system self; };
            };
          }
        ],
        extraSpecialArgs ? { },
      }:
      nixosSystem {
        modules =
          profiles
          ++ extraModules
          ++ [
            {
              networking.hostName = name;
              nixpkgs.hostPlatform = system;
            }
            ./${name}
          ];

        specialArgs = {
          inherit inputs self;
        } // extraSpecialArgs;
      };

    mkHome =
      name: system:
      homeManagerConfiguration {
        pkgs = import nixpkgs { inherit system; };

        modules = [
          homeManagerModules.default
          nixvim.homeManagerModules.nixvim
          ./${name}
        ];

        extraSpecialArgs = {
          inherit inputs self system;
        };
      };

  };

  perSystem._module.args.lib = inputs.nixpkgs.lib.extend self.overlays.lib;
}
