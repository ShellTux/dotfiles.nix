{ config, lib, ... }:
let
  inherit (lib) mkIf;
in
mkIf (config.flavour == "config1") {
  settings = {
    embed-thumbnail = true;
    embed-subs = true;
    embed-metadata = true;
    embed-chapters = true;
    sub-langs = "all";
    format = ''"bestvideo[height<=1440]+bestaudio/best"'';
  };
}
