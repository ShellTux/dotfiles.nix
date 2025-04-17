{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkOption mkIf mkDefault;
  inherit (lib.types) bool;

  domain = "example.com";
  subdomain = "paperless.${domain}";

  cfg = config.services.paperless;
in
{
  options.services.paperless = {
    disableModule = mkOption {
      description = "Whether to disable this module configuration";
      type = bool;
      default = false;
    };
  };

  config = mkIf (cfg.enable && !cfg.disableModule) {
    services.paperless = mkDefault { };

    services.caddy.virtualHosts = {
      "${subdomain}".extraConfig = ''
        encode zstd gzip

        reverse_proxy :${cfg.port |> toString} {
          header_up X-Real-IP {remote_host}
        }
      '';

      ":7001".extraConfig = ''
        import https
        import reverse-proxy 127.0.0.1 ${cfg.port |> toString}
      '';
    };
  };
}
