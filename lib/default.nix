inputs: final: prev:
let
  lib-import =
    path:
    import path {
      inherit inputs final prev;
      lib = prev;
    };
in
{
  flake = lib-import ./flake;
}
