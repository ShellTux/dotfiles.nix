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
    mkDefault
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
      '';

      extraConfig = ''
        # Snippets

        (https) {
          # tls /var/lib/caddy/homeapps.crt /var/lib/caddy/homeapps.key
          # tls /var/lib/caddy/homeapps+1.pem /var/lib/caddy/homeapps+1-key.pem
          # tls internal {
          #    on_demand
          # }
        }

        (reverse-proxy) {
            reverse_proxy {args[0]}:{args[1]} {
                #@error status 500 502 503
                #handle_response @error {
                #   respond "Not found"
                #}
            }
        }

        # (reverse-proxy-https) {
        #     reverse_proxy https://{args[0]}:{args[1]} {
        #                 transport http {
        #                         tls_insecure_skip_verify
        #                 }
        #         }
        # }
      '';

      virtualHosts = {
        ":9900".extraConfig = ''
          respond "Hello world from 9900"
        '';
        ":9901".extraConfig = ''
          import https
          import reverse-proxy 127.0.0.1 9900
          # respond "Hello world from https://:9901"
        '';
      };
    };

    networking.firewall.allowedTCPPorts = caddyPorts;
  };
}
