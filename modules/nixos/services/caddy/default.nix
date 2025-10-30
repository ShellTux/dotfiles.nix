{
  config,
  lib,
  ...
}:
let
  inherit (builtins) attrNames filter;
  inherit (lib)
    mkOption
    mkIf
    substring
    toIntBase10
    hasPrefix
    ;
  inherit (lib.types) bool;

  caddyPorts =
    config.services.caddy.virtualHosts
    |> attrNames
    |> filter (vh: vh |> hasPrefix ":")
    |> map (vh: vh |> substring 1 999999 |> toIntBase10);

  cfg = config.services.caddy;
in
{
  options.services.caddy = {
    disableModule = mkOption {
      description = "Whether to disable this module configuration";
      type = bool;
      default = false;
    };
  };

  config = mkIf (cfg.enable && !cfg.disableModule) {
    services.caddy = {
      globalConfig = ''
        email admin@email.caddy
        http_port 8080
        https_port 8443
      '';

      extraConfig =
        let
          crt = config.sops.secrets."caddy/tls/crt";
          key = config.sops.secrets."caddy/tls/key";
        in
        ''
          # Snippets

          (https) {
            tls ${crt.path} ${key.path}
          }

          (reverse-proxy) {
              reverse_proxy {args[0]}:{args[1]} {
                  # @error status 500 502 503
                  # handle_response @error {
                  #    respond "Not found"
                  # }
              }
          }
        '';

      virtualHosts = {
        ":9900".extraConfig = ''
          respond "Hello world from 9900"
        '';

        ":9901".extraConfig = ''
          import https
          import reverse-proxy 127.0.0.1 9900
        '';
      };
    };

    networking.firewall.allowedTCPPorts = caddyPorts;

    sops.secrets = {
      "caddy/tls/crt" = {
        owner = config.services.caddy.user;
        restartUnits = [ "caddy.service" ];
      };

      "caddy/tls/key" = {
        owner = config.services.caddy.user;
        restartUnits = [ "caddy.service" ];
      };
    };

  };
}
