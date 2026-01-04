{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) getExe getExe';

  firewall-applet = getExe' pkgs.firewalld-gui "firewall-applet";
  gammastep = getExe pkgs.gammastep;
  networkmanagerapplet = getExe pkgs.networkmanagerapplet;
  qpwgraph = getExe pkgs.qpwgraph;
  waybar = getExe config.programs.waybar.package;
in
{
  wayland.windowManager.hyprland.settings.exec-once = [
    "${firewall-applet}"
    "${gammastep}"
    "${networkmanagerapplet}"
    "${qpwgraph} --minimized"
    "${waybar}"
  ];
}
