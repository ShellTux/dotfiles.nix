{
  self,
  inputs,
  lib,
  ...
}:
let
  inherit (lib) mkOption types;
  inherit (types) attrs;
in
{
  flake.nixosModules.default = {
    imports = [
      inputs.disko.nixosModules.disko
      inputs.home-manager.nixosModules.home-manager
      inputs.nix-index-database.nixosModules.nix-index
      inputs.nixvim.nixosModules.nixvim
      inputs.sops-nix.nixosModules.sops
      inputs.stylix.nixosModules.stylix
    ]
    ++ [
      ./boot
      ./console
      ./documentation
      ./fonts
      ./hardware
      ./networking
      ./nix
      ./options
      ./programs
      ./security
      ./services
      ./stylix
      ./systemd
      ./virtualisation
    ];

    options.inspect = {
      self = mkOption {
        description = "Debugging option to inspect self";
        type = attrs;
        default = self;
      };

      inputs = mkOption {
        description = "Debugging option to inspect inputs";
        type = attrs;
        default = inputs;
      };

      lib = mkOption {
        description = "Debugging option to inspect lib ${lib.double 4}";
        type = attrs;
        default = lib;
      };
    };
  };
}
