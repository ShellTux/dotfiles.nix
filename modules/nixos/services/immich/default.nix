{
  config,
  lib,
  lib',
  ...
}:
let
  inherit (builtins) elem map listToAttrs;
  inherit (lib)
    mkDefault
    mkEnableOption
    mkForce
    mkIf
    mkOption
    optionals
    pipe
    removeSuffix
    ;
  inherit (lib.types) bool str listOf;
  inherit (lib'.flake.networking) mkSiteOptions;

  cfg = config.services.immich;
in
{
  options.services.immich = {
    disableModule = mkOption {
      description = "Whether to disable this module configuration";
      type = bool;
      default = false;
    };

    site = mkSiteOptions {
      subdomain = "immich";
      inherit (config.networking) fqdnOrHostName localFqdn;
      description = "Self-hosted photo and video management solution. Easily back up, organize, and manage your photos on your own server. Immich helps you browse, search and organize your photos and videos with ease, without sacrificing your privacy.";
    };

    hardwareAcceleration = mkEnableOption "Whether to enable hardware acceleration";

    extraGroups = mkOption {
      description = "immich extra groups";
      type = listOf str;
      default = [ ];
    };

    externalLibraries = mkOption {
      description = "Immich external libraries";
      type = listOf str;
      default = [ ];
    };
  };

  config = mkIf (cfg.enable && !cfg.disableModule) {
    services.immich = {
      host = "127.0.0.1";

      accelerationDevices = mkIf cfg.hardwareAcceleration null;

      environment = {
        IMMICH_LOG_LEVEL = "verbose";
      };
    };

    services = {
      caddy.virtualHosts = {
        "${cfg.site.fqdn}" = mkIf (elem "public" cfg.site.exposure) {
          extraConfig = ''
            import tls-public
            import encoding
            import coraza
            import reverse-proxy 127.0.0.1:${toString cfg.port}
          '';
        };

        "${cfg.site.localFqdn}" = mkIf (elem "local" cfg.site.exposure) {
          extraConfig = ''
            import tls-local
            import encoding
            import reverse-proxy 127.0.0.1:${toString cfg.port}
          '';
        };
      };

      homepage-dashboard.service-templates.immich = {
        display = "Immich";
        inherit (cfg.site)
          href
          ping
          siteMonitor
          description
          ;
        icon = "immich.png";

        widget = {
          enable = mkDefault false;
          url = cfg.site.href;

          type = "immich";
          key = "{{HOMEPAGE_VAR_IMMICH_KEY}}";
          version = 2;
        };
      };
    };

    programs.rust-motd.settings.service_status.Immich =
      removeSuffix ".service" config.systemd.services.immich-server.name;

    users.users.${cfg.user}.extraGroups =
      cfg.extraGroups
      ++ optionals cfg.hardwareAcceleration [
        "video"
        "render"
      ];

    fileSystems = pipe cfg.externalLibraries [
      (map (
        l:
        let
          mountPoint = "/usr/local/immich/external-libraries/${l}";
          device = l;
        in
        {
          name = mountPoint;

          value = {
            inherit device;
            fsType = "none";
            options = [
              "bind"
              "ro" # Read only
              "x-mount.mkdir" # Create directory if doesn't exist
            ];
            autoFormat = mkForce false;
            autoResize = mkForce false;
          };
        }
      ))
      listToAttrs
    ];
  };
}
