{
  lib,
  ...
}:
let
  inherit (lib) mkDefault;
in
{
  nix.settings = {
    experimental-features = mkDefault [
      "flakes"
      "nix-command"
    ];
    auto-optimise-store = mkDefault true;
  };
}
