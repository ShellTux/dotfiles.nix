args@{ lib, ... }:
let
  inherit (builtins) listToAttrs;
  inherit (lib) pipe;
in
pipe
  [
    ./caddy
    ./homepage-dashboard
    ./hyprland
    ./nginx
  ]
  [
    (map (path: {
      name = baseNameOf path;
      value = import path args;
    }))
    listToAttrs
  ]
