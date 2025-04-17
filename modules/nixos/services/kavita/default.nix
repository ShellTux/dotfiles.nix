{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkOption mkIf mkDefault;
  inherit (lib.types) bool;

  domain = "example.com";
  subdomain = "kavita.${domain}";

  cfg = config.services.kavita;
in
{
  options.services.kavita = {
    disableModule = mkOption {
      description = "Whether to disable this module configuration";
      type = bool;
      default = false;
    };
  };

  config = mkIf (cfg.enable && !cfg.disableModule) {
    services.kavita = mkDefault { };

    services.caddy.virtualHosts = {
      "${subdomain}".extraConfig = ''
        encode zstd gzip

        reverse_proxy :${cfg.settings.Port |> toString} {
          header_up X-Real-IP {remote_host}
        }
      '';

      ":7005".extraConfig = ''
        import https
        import reverse-proxy 127.0.0.1 ${cfg.settings.Port |> toString}
      '';
    };
  };
}
