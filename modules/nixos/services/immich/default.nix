{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (builtins)
    length
    map
    listToAttrs
    ;
  inherit (lib)
    mkOption
    mkIf
    mkForce
    getExe'
    flatten
    pipe
    ;
  inherit (lib.types) bool str listOf;

  mount = getExe' pkgs.util-linux "mount";
  umount = getExe' pkgs.util-linux "umount";

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
      default = "immich.${config.server.domain}";
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

    services.caddy.virtualHosts = {
      "${cfg.subdomain}".extraConfig = ''
        encode zstd gzip

        reverse_proxy :${cfg.port |> toString} {
          header_up X-Real-IP {remote_host}
        }
      '';

      ":${toString config.server.reverse-proxy.port.immich}".extraConfig = ''
        import https
        import reverse-proxy 127.0.0.1 ${cfg.port |> toString}
      '';
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
