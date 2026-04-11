{
  self,
  inputs,
  config,
  withSystem,
  ...
}:
let
  inherit (builtins) attrValues;
  inherit (inputs) dev-tools;
  inherit (inputs.nixpkgs.lib) nixosSystem;
  inherit (config.flake) nixosModules homeManagerModules packages;

  profiles = import "${self}/profiles";
  lib' = self.lib;

  mkHost =
    {
      name,
      system,
      extraProfiles ? [ profiles.system.core ],
      extraModules ? [ ],
      extraSpecialArgs ? { },
    }:
    withSystem system (
      {
        inputs',
        self',
        ...
      }:
      nixosSystem {
        modules =
          extraProfiles
          ++ extraModules
          ++ [
            nixosModules.default

            {
              sops.age.keyFile = "/var/lib/sops/age/keys.txt";

              nixpkgs = {
                overlays = [ (import ../overlays.nix { inherit inputs; }) ];
                config.packageOverrides = pkgs: {
                  small = import inputs.nixpkgs-small { inherit system; };
                  stable = import inputs.nixpkgs-stable { inherit system; };
                };
              };

              home-manager = {
                useUserPackages = true;
                useGlobalPkgs = true;
                sharedModules = attrValues homeManagerModules;
                extraSpecialArgs = {
                  inherit
                    inputs
                    system
                    self
                    self'
                    lib'
                    ;

                  dev-tools = dev-tools.packages.${system};
                };
              };
            }

            {
              networking.hostName = name;
              nixpkgs.hostPlatform = system;
            }

            ./${name}
          ];

        specialArgs = {
          inherit
            inputs
            inputs'
            self
            self'
            system
            lib'
            ;
        }
        // extraSpecialArgs;
      }
    );
in
{
  flake.nixosConfigurations = {

    laptop = mkHost {
      name = "laptop";
      system = "x86_64-linux";
      extraProfiles = [
        profiles.system.laptop
        (profiles.locale "pt")
      ];
    };

    ra = mkHost {
      name = "ra";
      system = "x86_64-linux";
      extraProfiles = [
        (profiles.locale "pt")
      ];
    };

    # For Unit testing purposes
    test = mkHost {
      name = "test";
      system = "x86_64-linux";
    };

  };
}
