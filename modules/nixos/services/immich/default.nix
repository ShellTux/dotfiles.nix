{
  config,
  lib,
  flake-lib,
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
  inherit (lib.types)
    bool
    str
    listOf
    port
    ;
  inherit (flake-lib.caddy) genVirtualHosts;

  cfg = config.services.immich;
in
{
  options.services.immich = {
    disableModule = mkOption {
      description = "Whether to disable this module configuration";
      type = bool;
      default = false;
    };

    subdomain = mkOption {
      description = "subdomain";
      type = str;
      default = "immich";
    };

    reverse-proxy.port = {
      external = mkOption {
        description = "Reverse Proxy external port";
        type = port;
        default = 9908;
      };

      internal = mkOption {
        description = "Reverse Proxy internal port";
        type = port;
        default = cfg.port;
      };
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

    services.caddy.virtualHosts = genVirtualHosts {
      inherit (cfg) subdomain reverse-proxy;
    };

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
