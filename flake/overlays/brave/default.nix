{ pkgs, lib, ... }:
let
  inherit (builtins) readFile fromJSON;
  inherit (lib) recursiveUpdate mapAttrs pipe;

  extensions = pipe ./extensions.json [
    readFile
    fromJSON
    (mapAttrs (extension: id: { inherit id; }))
    (recursiveUpdate (pkgs.brave.extensions or { }))
  ];
in
{
  overlayAttrs.brave = pkgs.brave // {
    inherit extensions;
  };
}
