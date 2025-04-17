{ gf }:
gf.overrideAttrs (
  { patches, ... }:
  {
    patches = patches ++ [ ./hyprland.patch ];
  }
)
