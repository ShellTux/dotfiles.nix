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
    ./firefox
    ./homepage-dashboard
    ./hyprland
    ./mkFlavourOption
    ./mkIfFlavour
    ./nginx
    ./restic
  ]
  [
    (map (path: {
      name = baseNameOf path;
      value = import path args;
    }))
    listToAttrs
  ]
