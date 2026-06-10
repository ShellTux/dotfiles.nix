{ lib, ... }:
let
  inherit (lib) pipe attrsToList;
in
{
  mkPruneOpts =
    opts:
    pipe opts [
      attrsToList
      (map ({ name, value }: "--keep-${name}=${toString value}"))
    ];
}
