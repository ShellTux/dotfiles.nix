{
  lib,
  ...
}:
let
  inherit (lib) mkDefault;
in
{
  programs.nixvim.plugins.cloak.settings = mkDefault {
    cloak_character = "*";
    highlight_group = "Comment";
    patterns = [
      {
        cloak_pattern = [
          "=.+"
          "pass.+"
          ":.+"
          "-.+"
        ];
        file_pattern = [
          ".env*"
          "wrangler.toml"
          ".dev.vars"
          "*.crypt.nix"
          "*secrets*.yaml"
          "*secrets*.yml"
        ];
      }
    ];
  };
}
