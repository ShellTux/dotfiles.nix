{ inputs, ... }:
let
  inherit (inputs.nixpkgs.lib)
    pipe
    filterAttrs
    mapAttrsToList
    concatStringsSep
    ;
in
{
  hyprland = {
    windowrule =
      let
        effect = effect: match: "${effect}, ${match}";
      in
      {
        anonymous =
          {
            match ? {
              class = null;
            },
            effects ? {
              idle_inhibit = null;
            },
          }:
          concatStringsSep ", " (
            (pipe match [
              (filterAttrs (_: v: v != null))
              (mapAttrsToList (k: v: "match:${k} ${v}"))
            ])
            ++ (pipe effects [
              (filterAttrs (_: v: v != null))
              (mapAttrsToList (k: v: "${k} ${v}"))
            ])
          );

        float = effect "float";
        idleinhibit = mode: rule: "idleinhibit ${mode}, ${rule}";
        noborder = effect "noborder";
        opaque = effect "opaque";
        pin = effect "pin";
        size = width: height: effect "size ${width} ${height}";
        workspace = number: effect "workspace ${toString number}";
      };
  };

  double = a: a * 2;
}
