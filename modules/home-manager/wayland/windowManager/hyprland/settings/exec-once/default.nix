{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkDefault getExe getExe';

  firewall-applet = getExe' pkgs.firewalld-gui "firewall-applet";
  gammastep = getExe pkgs.gammastep;
  networkmanagerapplet = getExe pkgs.networkmanagerapplet;
  qpwgraph = getExe pkgs.qpwgraph;
  pypr = getExe pkgs.pyprland;
  waybar = getExe config.programs.waybar.package;
in
{
  wayland.windowManager.hyprland.settings.exec-once = mkDefault [
    "${firewall-applet}"
    "${gammastep}"
    "${networkmanagerapplet}"
    "${qpwgraph} --minimized"
    "${waybar}"
    "${pypr}"
  ];
}
