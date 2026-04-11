inputs: final: prev:
let
  lib-import = path: import path { inherit inputs final prev; };
in
{
  flake = {
    caddy = lib-import ./caddy;
    homepage-dashboard = lib-import ./homepage-dashboard;
    hyprland = lib-import ./hyprland;
    nginx = lib-import ./nginx;
  };
}
