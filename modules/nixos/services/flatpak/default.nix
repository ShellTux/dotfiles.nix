{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkOption mkIf mkAfter;
  inherit (lib.types) bool;

  cfg = config.services.flatpak;
in
{
  options.services.flatpak = {
    disableModule = mkOption {
      description = "Whether to disable this module configuration";
      type = bool;
      default = false;
    };
  };

  config = mkIf (cfg.enable && !cfg.disableModule) {
    # flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

    environment = {
      systemPackages = [ pkgs.gnome-software ];
      sessionVariables.XDG_DATA_DIRS = mkAfter [
        "/var/lib/flatpak/exports/share"
        "$HOME/.local/share/flatpak/exports/share"
      ];
      profiles = [
        "/var/lib/flatpak/exports"
        "$HOME/.local/share/flatpak/exports"
      ];

    };
  };
}
