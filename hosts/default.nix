{
  self,
  inputs,
  config,
  lib,
  withSystem,
  ...
}:
let
  inherit (builtins) attrValues;
  inherit (lib) optional;
  inherit (inputs.nixpkgs.lib) nixosSystem;
  inherit (config.flake) nixosModules homeManagerModules;

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
    let
      overlays = [ self.overlays.default ] ++ optional (self.overlays ? ${name}) self.overlays.${name};
    in
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
                inherit overlays;

                config.packageOverrides = pkgs: {
                  small = import inputs.nixpkgs-small { inherit system overlays; };
                  stable = import inputs.nixpkgs-stable { inherit system overlays; };
                };
              };

              home-manager = {
                useUserPackages = true;

                sharedModules = attrValues homeManagerModules ++ [
                  {
                    nixpkgs = {
                      inherit overlays;

                      config.packageOverrides = pkgs: {
                        small = import inputs.nixpkgs-small { inherit system overlays; };
                        stable = import inputs.nixpkgs-stable { inherit system overlays; };
                      };
                    };
                  }
                ];
                extraSpecialArgs = {
                  inherit
                    inputs
                    system
                    self
                    self'
                    lib'
                    ;
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
