input@{
  inputs,
  self,
  lib,
  ...
}:
let
  inherit (lib) mkOption;
  inherit (lib.types) attrs;
in
{
  imports = [
    inputs.home-manager.flakeModules.default
  ];

  flake.homeManagerModules.default = {
    imports = [
      inputs.hyprshell.homeModules.hyprshell
      inputs.nix-index-database.homeModules.nix-index
      inputs.nixvim.homeModules.nixvim
      inputs.sops-nix.homeManagerModules.sops
      inputs.stylix.homeModules.stylix
    ]
    ++ [
      ./gtk
      ./home
      ./nix
      ./options
      ./programs
      ./qt
      ./services
      ./sops
      ./stylix
      ./wayland
      ./xdg
    ];

    options.inspect = {
      input = mkOption {
        description = "Debugging option to inspect input";
        type = attrs;
        default = input;
      };

      inputs = mkOption {
        description = "Debugging option to inspect inputs";
        type = attrs;
        default = inputs;
      };

      self = mkOption {
        description = "Debugging option to inspect self";
        type = attrs;
        default = self;
      };
    };
  };
}
