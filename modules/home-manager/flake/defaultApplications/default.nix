{
  self',
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (builtins) attrValues;
  inherit (lib)
    genAttrs
    mkOption
    pipe
    unique
    ;
  inherit (lib.types) enum;

  terminals =
    pipe pkgs.terminals [
      attrValues
      unique
    ]
    ++ [ self'.packages.kitty ];

  browsers = pipe pkgs.browsers [
    attrValues
    unique
  ];

  cfg = config.flake.defaultApplications;
in
{
  options.flake.defaultApplications = {
    terminal = mkOption {
      description = "Which default terminal to pick.";
      type = enum terminals;
      default = self'.packages.kitty;
    };

    browser = mkOption {
      description = "Which default browser to pick.";
      type = enum browsers;
      default = pkgs.brave;
    };
  };

  config.xdg.mimeApps.defaultApplications = genAttrs [
    "application/x-extension-htm"
    "application/x-extension-html"
    "application/x-extension-shtml"
    "application/x-extension-xht"
    "application/x-extension-xhtml"
    "application/xhtml+xml"
    "text/html"
    "x-scheme-handler/about"
    "x-scheme-handler/chrome"
    "x-scheme-handler/http"
    "x-scheme-handler/https"
    "x-scheme-handler/unknown"
  ] (_: "${cfg.browser.pname}.desktop");
}
