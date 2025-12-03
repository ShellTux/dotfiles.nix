{ inputs, self, ... }:
{
  flake.overlays.lib = final: prev: { };

  perSystem._module.args.lib = inputs.nixpkgs.lib.extend self.overlays.lib;
}
