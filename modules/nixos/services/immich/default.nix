{
  config,
  lib,
  lib',
  ...
}:
let
  inherit (builtins) map listToAttrs;
  inherit (lib)
    mkOption
    mkIf
    mkForce
    pipe
    ;
  inherit (lib.types) bool str listOf;
  inherit (lib'.flake.caddy) mkProxyOption;

  cfg = config.services.immich;
in
{
  options.services.immich = {
    disableModule = mkOption {
      description = "Whether to disable this module configuration";
      type = bool;
      default = false;
    };

    proxy = mkProxyOption {
      inherit (config.networking) naming;
      name = "immich";
      upstream.port = cfg.port;
    };

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

      environment = {
        IMMICH_LOG_LEVEL = "verbose";
      };
    };

    services.caddy.proxies = [ cfg.proxy ];

    programs.rust-motd.settings.service_status.Immich = "immich-server";

    users.users.${cfg.user}.extraGroups = cfg.extraGroups;

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
