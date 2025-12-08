{
  config,
  lib,
  flake-lib,
  ...
}:
let
  inherit (builtins) head;
  inherit (lib)
    mkOption
    mkIf
    pipe
    split
    reverseList
    toInt
    ;
  inherit (lib.types) bool str;
  inherit (flake-lib.caddy) genVirtualHosts;

  port = pipe cfg.listenAddress [
    (split ":")
    reverseList
    head
    toInt
  ];

  cfg = config.services.echoip;
in
{
  options.services.echoip = {
    disableModule = mkOption {
      description = "Whether to disable this module configuration";
      type = bool;
      default = false;
    };

    subdomain = mkOption {
      description = "subdomain";
      type = str;
      default = "echoip";
    };

    reverse-proxy.port = {
      external = mkOption {
        description = "Reverse Proxy external port";
        type = port;
        default = 9912;
      };

      internal = mkOption {
        description = "Reverse Proxy internal port";
        type = port;
        default = port;
      };
    };
  };

  config = mkIf (cfg.enable && !cfg.disableModule) {
    services.echoip = {
      listenAddress = ":8183";
    };

    programs.rust-motd.settings.service_status.Echoip = "echoip";

    networking.firewall.allowedTCPPorts = [ port ];

    services.caddy.virtualHosts = genVirtualHosts {
      inherit (cfg) subdomain reverse-proxy;
    };
  };
}
