{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (builtins) attrNames attrValues map;
  inherit (lib)
    mkOption
    mkIf
    mkDefault
    pipe
    ;
  inherit (lib.types) bool;

  cfg = config.networking.wireguard;
in
{
  options.networking.wireguard = {
    disableModule = mkOption {
      description = "Whether to disable this module configuration";
      type = bool;
      default = false;
    };
  };

  config = mkIf (cfg.enable && !cfg.disableModule) {
    networking = {
      nat = {
        enable = true;
        enableIPv6 = true;
        externalInterface = mkDefault "eth0";
        internalInterfaces = attrNames cfg.interfaces;
      };

      firewall.allowedUDPPorts = pipe config.networking.wireguard.interfaces [
        attrValues
        (map ({ listenPort, ... }: listenPort))
      ];
    };

    environment.systemPackages = [
      pkgs.wireguard-tools
    ];
  };
}
