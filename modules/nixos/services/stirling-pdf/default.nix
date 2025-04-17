{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkOption mkIf mkDefault;
  inherit (lib.types) bool;

  domain = "example.com";
  subdomain = "pdf.${domain}";

  cfg = config.services.stirling-pdf;
in
{
  options.services.stirling-pdf = {
    disableModule = mkOption {
      description = "Whether to disable this module configuration";
      type = bool;
      default = false;
    };
  };

  config = mkIf (cfg.enable && !cfg.disableModule) {
    services.stirling-pdf = mkDefault {
      environment = {
        INSTALL_BOOK_AND_ADVANCED_HTML_OPS = "true";
        SERVER_PORT = 9381;
      };
    };

    services.caddy.virtualHosts = {
      "${subdomain}".extraConfig = ''
        encode zstd gzip

        reverse_proxy :${cfg.environment.SERVER_PORT |> toString} {
          header_up X-Real-IP {remote_host}
        }
      '';

      ":7006".extraConfig = ''
        import https
        import reverse-proxy 127.0.0.1 ${cfg.environment.SERVER_PORT |> toString}
      '';
    };
  };
}
