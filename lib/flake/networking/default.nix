{ lib, ... }:
let
  inherit (builtins) elem;
  inherit (lib) mkOption types;
in
{
  mkSiteOptions =
    {
      fqdnOrHostName,
      localFqdn,
      subdomain,
      reverse-proxy ? "caddy",
      description,
    }:
    mkOption {
      type = types.submodule (
        { config, ... }: {
          options = {
            exposure = mkOption {
              type = types.listOf (
                types.enum [
                  "local"
                  "public"
                ]
              );
              default = [ ];
              example = [
                "public"
                "local"
              ];
            };

            description = mkOption {
              type = types.str;
              default = description;
            };

            reverse-proxy = mkOption {
              type = types.enum [
                "caddy"
                "nginx"
                "custom"
              ];
              default = reverse-proxy;
            };

            autheliaEnabled = mkOption {
              type = types.bool;
              default = false;
            };

            subdomain = mkOption {
              type = types.nullOr types.str;
              default = subdomain;
            };

            domain = mkOption {
              internal = true;
              type = types.str;
              default = "${subdomain}.${fqdnOrHostName}";
            };

            fqdn = mkOption {
              internal = true;
              type = types.str;
              default = "${subdomain}.${fqdnOrHostName}";
            };

            localFqdn = mkOption {
              internal = true;
              type = types.str;
              default = "${subdomain}.${localFqdn}";
            };

            href = mkOption {
              internal = true;
              type = types.str;
              default =
                if elem "public" config.exposure then "https://${config.fqdn}" else "https://${config.localFqdn}";
            };

            siteMonitor = mkOption {
              type = types.nullOr types.str;
              default = config.href;
            };

            ping = mkOption {
              type = types.nullOr types.str;
              default = config.href;
            };
          };
        }
      );
    };
}
