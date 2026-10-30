{ lib, config, ... }:
let
  inherit (builtins) concatStringsSep;
  inherit (lib)
    mapAttrsToList
    mkDefault
    mkIf
    mkOption
    pipe
    trim
    types
    ;

  inherit (config.networking) fqdnOrHostName;
  inherit (config.sops) secrets;

  cfg = config.services.caddy;
in
{
  options.services.caddy.snippets = mkOption {
    type = types.attrsOf types.str;
    description = "Snippets";
    default = { };
  };

  config.services.caddy = mkIf (cfg.enable && !cfg.disableModule) {
    snippets = {
      blocked-html = mkDefault ''
        body <<HTML
        <html>
            <p>
                Your IP address is {http.request.remote.host}.
                You aren't allowed!
                Ask admin for help.
            </p>
        </html>
        HTML
      '';

      encoding = mkDefault ''
        encode zstd gzip
      '';

      reverse-proxy = mkDefault ''
        reverse_proxy {args[0]} {
            header_up X-Real-IP {remote_host}
            header_up X-Forwarded-For {remote_host}
            header_up X-Forwarded-Proto {scheme}
            header_up X-Forwarded-Host {host}
        }
      '';

      tls-local = mkDefault ''
        tls ${secrets."tls/crt".path} ${secrets."tls/key".path} {
            issuer internal
        }
      '';

      tls-public = mkDefault ''
        tls {
            dns duckdns {$DUCKDNS_TOKEN} {
                override_domain ${fqdnOrHostName}
            }
        }
      '';

      coraza = mkDefault ''
        coraza_waf {
          load_owasp_crs

          directives `
            Include @coraza.conf-recommended
            Include @crs-setup.conf.example
            Include @owasp_crs/*.conf

            SecRuleEngine On
          `
        }
      '';
    };

    extraConfig = pipe cfg.snippets [
      (mapAttrsToList (
        name: config: ''
          (${name}) {
            ${trim config}
          }
        ''
      ))
      (concatStringsSep "\n\n")
    ];
  };
}
