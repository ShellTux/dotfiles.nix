{
  config,
  lib,
  lib',
  pkgs,
  ...
}:
let
  inherit (builtins)
    attrNames
    lessThan
    match
    sort
    ;
  inherit (lib)
    flatten
    mkIf
    mkOption
    pipe
    toIntBase10
    ;
  inherit (lib.lists) unique;
  inherit (lib.types) bool attrs;
  inherit (lib'.flake.caddy) mkProxiesOption;

  caddyPorts = pipe cfg.virtualHosts [
    attrNames
    (map (match ".*:([0-9]+)"))
    (map (m: if m == null then [ "443" ] else m))
    flatten
    unique
    (map toIntBase10)
    (sort lessThan)
  ];

  cfg = config.services.caddy;
in
{
  imports = [
    ./authelia
    ./snippets
    ./virtualHosts
  ];

  options.services.caddy = {
    disableModule = mkOption {
      description = "Whether to disable this module configuration";
      type = bool;
      default = false;
    };

    secrets.options = mkOption {
      internal = true;
      type = attrs;
      default = {
        owner = cfg.user;
        restartUnits = [ "caddy.service" ];
      };
    };

    proxies = mkProxiesOption { inherit (config.networking) naming; };
  };

  config = mkIf (cfg.enable && !cfg.disableModule) {
    services.caddy = {
      package = pkgs.caddy.withPlugins {
        plugins = [
          "github.com/caddy-dns/duckdns@v0.5.0"
          "github.com/porech/caddy-maxmind-geolocation@v1.0.3"
          "github.com/corazawaf/coraza-caddy/v2@v2.6.1"
        ];
        hash = "sha256-mQnH8pcJO3+2BSUrxQYLXbj6UwzW4SqYM7yyOTHaDiQ=";
      };

      globalConfig = ''
        order coraza_waf first
      '';

      environmentFile = config.sops.secrets."services/caddy/environmentFile".path;
    };

    networking.firewall.allowedTCPPorts = caddyPorts;

    programs.rust-motd.settings.service_status.Caddy = "caddy";

    sops.secrets = {
      "tls/crt" = cfg.secrets.options;
      "tls/key" = cfg.secrets.options;
      "services/caddy/environmentFile" = cfg.secrets.options;
    };
  };
}
