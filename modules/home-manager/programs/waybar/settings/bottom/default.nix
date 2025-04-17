{ config, lib, ... }:
let
  inherit (lib) mkIf mkDefault;

  cfg = config.programs.waybar;
in
{
  config = mkIf (cfg.enable && !cfg.disableModule) {
    programs.waybar.settings.bottom = mkDefault {
      name = "bottom_bar";
      layer = "top";
      position = "bottom";
      height = 36;
      spacing = 4;
      modules-left = [ "user" ];
      modules-center = [ "hyprland/window" ];
      modules-right = [
        "keyboard-state"
        "hyprland/language"
      ];

      "hyprland/window" = {
        format = "👼 {title} 😈";
        max-length = 50;
      };

      "hyprland/language" = {
        format-en = "🇺🇸 ENG (US)";
        format-pt = "🇵🇹 POR (PT)";
      };

      keyboard-state = {
        capslock = true;
        numlock = true;
        format = "{name} {icon}";
        format-icons = {
          locked = "󰌾";
          unlocked = "󰍀";
        };
      };

      user = {
        format = " <span color='#8bd5ca'>{user}</span> (up <span color='#f5bde6'>{work_d} d</span> <span color='#8aadf4'>{work_H} h</span> <span color='#eed49f'>{work_M} min</span> <span color='#a6da95'>↑</span>)";
        icon = true;
      };
    };
  };
}
