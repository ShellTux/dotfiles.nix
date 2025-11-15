{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkIf;

  cfg = config.programs.yazi;
in
{
  programs.yazi = mkIf (cfg.enable && !cfg.disableModule) {
    settings.open = {
      rules = [
        {
          mime = "text/*";
          use = [
            "edit"
            "reveal"
          ];
        }
        {
          mime = "image/*";
          use = [
            "image"
            "reveal"
          ];
        }
        {
          mime = "video/*";
          use = [
            "video"
            "reveal"
          ];
        }
        {
          mime = "audio/*";
          use = [
            "audio"
            "reveal"
          ];
        }
        {
          mime = "application/json";
          use = [
            "edit"
            "reveal"
          ];
        }
        {
          mime = "application/{gzip,zip,x-tar,x-bzip,x-bzip2,x-7z-compressed,x-rar,xz}";
          use = [
            "extract"
            "reveal"
          ];
        }
        {
          mime = "*";
          use = [
            "open"
            "reveal"
          ];
        }
      ];

      prepend_rules = [
        {
          name = "*.json";
          use = [ "edit" ];
        }
        {
          name = "*.html";
          use = [
            "open"
            "edit"
          ];
        }
        {
          name = "*.xopp";
          use = [
            "open"
            "extract"
            "reveal"
          ];
        }
      ];

      append_rules = [ ];
    };
  };
}
