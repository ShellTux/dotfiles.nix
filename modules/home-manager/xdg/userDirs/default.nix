{ config, lib, ... }:
let
  inherit (lib) mkOption mkIf mkDefault;
  inherit (lib.types) bool;
  inherit (config.home) homeDirectory;

  userDir = dir: "${homeDirectory}/${dir}";

  userDirs = {
    pt = {
      desktop = userDir "Área de Trabalho";
      documents = userDir "Documentos";
      download = userDir "Transferências";
      music = userDir "Música";
      pictures = userDir "Imagens";
      publicShare = userDir "Público";
      templates = userDir "Modelos";
      videos = userDir "Vídeos";
    };
  };

  cfg = config.xdg.userDirs;
in
{
  options.xdg.userDirs = {
    disableModule = mkOption {
      description = "Whether to disable this module configuration";
      type = bool;
      default = false;
    };
  };

  config = mkIf (cfg.enable && !cfg.disableModule) {
    xdg.userDirs = mkDefault userDirs.pt;
  };
}
