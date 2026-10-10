{ lib, config, ... }:
let
  inherit (lib) mkIf optionalString;
  inherit (config.networking.naming) fqdn;
  inherit (config.sops) secrets;

  cfg = config.services.caddy;
in
{
  services.caddy = mkIf (cfg.enable && !cfg.disableModule) {
    extraConfig = ''
      # Snippets

      (blocked-html) {
          body <<HTML
          <html>
              <p>
                  Your IP address is {http.request.remote.host}.
                  You aren't allowed!
                  Ask admin for help.
              </p>
          </html>
          HTML
      }

      (tls-local) {
        tls ${secrets."tls/crt".path} ${secrets."tls/key".path} {
            issuer internal
        }
      }

      (subdomain-local) {
        import tls-local
        encode zstd gzip

        reverse_proxy {args[0]} {
            header_up X-Real-IP {remote_host}
            header_up X-Forwarded-For {remote_host}
            header_up X-Forwarded-Proto {scheme}
            header_up X-Forwarded-Host {host}
        }
      }

      (subpath-local) {
          @{args[0]}-local path /{args[0]} /{args[0]}/*
          handle @{args[0]}-local {
              @{args[0]}-local-blocked not remote_ip private_ranges
              header @{args[0]}-local-blocked Content-Type "text/html"

              respond @{args[0]}-local-blocked 403 {
                  import blocked-html
              }
          }

          handle_path /{args[0]}* {
            reverse_proxy {args[1]} {
                header_up X-Real-IP {remote_host}
                header_up X-Forwarded-For {remote_host}
                header_up X-Forwarded-Proto {scheme}
                header_up X-Forwarded-Host {host}
                header_up X-Forwarded-Prefix /{args[0]}
            }
          }
      }

      (protected-endpoint) {
        forward_auth {args[0]} {
          uri /api/authz/forward-auth
          {block}
          copy_headers Remote-User Remote-Groups Remote-Email Remote-Name
        }
      }

      (protected-coraza) {
        coraza_waf {
          load_owasp_crs

          directives `
            Include @coraza.conf-recommended
            Include @crs-setup.conf.example
            Include @owasp_crs/*.conf

            SecRuleEngine On

            SecAuditEngine RelevantOnly
            SecAuditLog /var/log/coraza/audit.log
            SecAuditLogFormat JSON
          `
        }
      }
    ''
    + optionalString (fqdn != null) ''

      (tls-duckdns) {
          tls {
              dns duckdns {$DUCKDNS_TOKEN} {
                  override_domain ${fqdn}
              }
          }
      }

      (subdomain-public) {
        import tls-duckdns
        encode zstd gzip

        reverse_proxy {args[0]} {
            header_up X-Real-IP {remote_host}
            header_up X-Forwarded-For {remote_host}
            header_up X-Forwarded-Proto {scheme}
            header_up X-Forwarded-Host {host}
        }
      }

      (subpath-public) {
          @{args[0]}-public path /{args[0]} /{args[0]}/*
          handle @{args[0]}-public {
          }

          handle_path /{args[0]}* {
            reverse_proxy {args[1]} {
                header_up X-Real-IP {remote_host}
                header_up X-Forwarded-For {remote_host}
                header_up X-Forwarded-Proto {scheme}
                header_up X-Forwarded-Host {host}
                header_up X-Forwarded-Prefix /{args[0]}
            }
          }
      }
    '';
  };
}
