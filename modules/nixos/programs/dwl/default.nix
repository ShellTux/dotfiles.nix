{
  inputs,
  system,
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkOption mkIf mkDefault;
  inherit (lib.types) bool listOf package;

  name = "dwl-slstatus";
  dwl = inputs.dwl.packages.${system}.dwl;
  slstatus = inputs.slstatus.packages.${system}.slstatus;

  dwlSlstatusDesktopFile = pkgs.writeTextFile {
    name = "${name}-desktop-entry";
    destination = "/share/wayland-sessions/${name}.desktop";
    text = ''
      [Desktop Entry]
      Name=${name}
      Comment=Dynamic window manager for Wayland
      Exec=/etc/xdg/${name}-session
      Type=Application
    '';
  };

  dwlSession = pkgs.symlinkJoin {
    name = "${name}-session";
    paths = [ dwlSlstatusDesktopFile ];
    passthru.providedSessions = [ name ];
  };

  cfg = config.programs.dwl;
in
{
  options.programs.dwl = {
    disableModule = mkOption {
      description = "Whether to disable this module configuration";
      type = bool;
      default = false;
    };

    # TODO: add option to set slstatus package

    extraPackages = mkOption {
      description = "Useful extra packages to install along side with dwl";
      type = listOf package;
      default = [
        pkgs.kitty
        pkgs.libnotify
        pkgs.pavucontrol
        pkgs.pw-volume
        pkgs.pwvucontrol
        pkgs.qpwgraph
        pkgs.wofi
      ]
      ++ [
        # Pyprland
        pkgs.btop
        pkgs.htop
        pkgs.hyprpicker
        pkgs.hyprshot
        pkgs.libqalculate
        pkgs.pyprland
        pkgs.satty
        pkgs.yazi
      ]
      ++ [
        pkgs.wl-clipboard
        pkgs.grim
        pkgs.slurp
        pkgs.wf-recorder
      ]
      ++ [
        # ncmpcpp
        # brightness
        # volume
      ];
      example = [ ];
    };
  };

  config = mkIf (cfg.enable && !cfg.disableModule) {

    programs.dwl = mkDefault {
    };

    environment.systemPackages = cfg.extraPackages;

    xdg.portal = {
      enable = true;
      extraPortals = [
        pkgs.xdg-desktop-portal-gtk
        pkgs.xdg-desktop-portal-hyprland
        pkgs.xdg-desktop-portal-wlr
      ];
    };

    # Create systemd target for dwl session
    systemd.user.targets."${name}-session" = {
      description = "${name} compositor session";
      documentation = [ "man:systemd.special(7)" ];
      bindsTo = [ "graphical-session.target" ];
      wants = [ "graphical-session-pre.target" ];
      after = [ "graphical-session-pre.target" ];
    };

    # Create wrapper script for dwl
    environment.etc."xdg/${name}-session" = {
      text = ''
        #!${pkgs.runtimeShell}
        # Import environment variables
        ${cfg.extraSessionCommands}
        # Setup systemd user environment
        systemctl --user import-environment DISPLAY WAYLAND_DISPLAY
        systemctl --user start ${name}-session.target
        # Start dwl
        ${slstatus}/bin/slstatus -s | exec ${dwl}/bin/dwl
      '';
      mode = "0755"; # Make it executable
    };

    # Create desktop entry for display managers
    services = {
      displayManager.sessionPackages = [ dwlSession ];
      xserver.excludePackages = [ pkgs.xterm ];
    };
  };
}
