{ self, inputs, ... }:
let
  inherit (builtins) elem;
in
{
  perSystem =
    { config, ... }:
    {
      nix-unit = {
        inputs = {
          # NOTE: a `nixpkgs-lib` follows rule is currently required
          inherit (inputs) nixpkgs flake-parts nix-unit;
        };

        # Tests specified here may refer to system-specific attributes that are
        # available in the `perSystem` context
        tests = {
          # "test passing per system" = {
          #   expr = "123";
          #   expected = "123";
          # };
          #
          # "test failing per system" = {
          #   "testFoo" = {
          #     expr = "foo";
          #     expected = "bar";
          #   };
          # };
        };
      };
    };

  flake.tests = {
    # "test passing system agnostic" = {
    #   expr = 1;
    #   expected = 1;
    # };
    #
    # "test failing system agnostic" = {
    #   expr = 1;
    #   expected = 2;
    # };

    "Home Manager Test" = {
      wayland.windowManager.hyprland.settings = {
        bind = {
          "test mainMod Terminal" = {
            expr = elem "$mainMod, Return, exec, $TERMINAL" self.outputs.homeConfigurations.test.config.wayland.windowManager.hyprland.settings.bind;
            expected = true;
          };
        };
      };
    };

    "Default sops.age.keyFile" = {
      "test - NixOS Configuration sops.age.keyFile" = {
        expr = self.nixosConfigurations.test.config.sops.age.keyFile;
        expected = "/var/lib/sops/age/keys.txt";
      };

      "test - NixOS HomeManager Configuration sops.age.keyFile" = {
        expr = self.nixosConfigurations.laptop.config.home-manager.users.luisgois.sops.age.keyFile;
        expected = "/home/luisgois/.config/sops/age/keys.txt";
      };

      "test - HomeManager Configuration sops.age.keyFile" = {
        expr = self.homeConfigurations.luisgois.config.sops.age.keyFile;
        expected = "/home/luisgois/.config/sops/age/keys.txt";
      };
    };
  };
}
