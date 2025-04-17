{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkOption mkIf mkDefault;
  inherit (lib.types) bool;

  domain = "example.com";
  subdomain = "forgejo.${domain}";

  cfg = config.services.forgejo;
in
{
  options.services.forgejo = {
    disableModule = mkOption {
      description = "Whether to disable this module configuration";
      type = bool;
      default = false;
    };
  };

  config = mkIf (cfg.enable && !cfg.disableModule) {
    services.forgejo = mkDefault { };

    services.caddy.virtualHosts = {
      "${subdomain}".extraConfig = ''
        encode zstd gzip

        reverse_proxy :${cfg.settings.server.HTTP_PORT |> toString} {
          header_up X-Real-IP {remote_host}
        }
      '';

      ":7004".extraConfig = ''
        import https
        import reverse-proxy 127.0.0.1 ${cfg.settings.server.HTTP_PORT |> toString}
      '';
    };
  };
}
