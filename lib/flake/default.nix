args@{ lib, ... }:
let
  inherit (builtins) listToAttrs;
  inherit (lib) pipe;
in
pipe
  [
    ./caddy
    ./dirs
    ./dirsNames
    ./homepage-dashboard
    ./hyprland
    ./mkFlavourOption
    ./mkIfFlavour
    ./nginx
  ]
  [
    (map (path: {
      name = baseNameOf path;
      value = import path args;
    }))
    listToAttrs
  ]
