{
  self,
  inputs,
  config,
  ...
}:
let
  inherit (builtins) attrValues;
  inherit (inputs.nixpkgs.lib) nixosSystem;
  inherit (config.flake) nixosModules homeManagerModules packages;

  profiles = import "${self}/profiles";

  mkHost =
    {
      name,
      system,
      extraProfiles ? [ profiles.system.core ],
      extraModules ? [
        nixosModules.default
        {
          sops.age.keyFile = "/var/lib/sops/age/keys.txt";

          home-manager = {
            useUserPackages = true;
            useGlobalPkgs = true;
            sharedModules = attrValues homeManagerModules;
            extraSpecialArgs = {
              inherit inputs system self;

              flake-pkgs = packages.${system};
            };
          };
        }
      ],
      extraSpecialArgs ? { },
    }:
    nixosSystem {
      modules =
        extraProfiles
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

        flake-pkgs = packages.${system};
      } // extraSpecialArgs;
    };
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

    # For Unit testing purposes
    test = mkHost {
      name = "test";
      system = "x86_64-linux";
    };

  };
}
