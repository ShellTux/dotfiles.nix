{
  config,
  lib,
  flake-lib,
  ...
}:
let
  inherit (builtins) elem concatStringsSep any;
  inherit (lib)
    mkOption
    mkIf
    head
    pipe
    ;
  inherit (lib.types) bool str port;
  inherit (flake-lib.caddy) genVirtualHosts;

  cfg = config.services.forgejo;
in
{
  options.services.forgejo = {
    disableModule = mkOption {
      description = "Whether to disable this module configuration";
      type = bool;
      default = false;
    };

    subdomain = mkOption {
      description = "subdomain";
      type = str;
      default = "forgejo";
    };

    reverse-proxy.port = {
      external = mkOption {
        description = "Reverse Proxy external port";
        type = port;
        default = 9910;
      };

      internal = mkOption {
        description = "Reverse Proxy internal port";
        type = port;
        default = 50610;
      };
    };
  };

  config = mkIf (cfg.enable && !cfg.disableModule) {
    warnings =
      let
        inherit (config.services.openssh.settings) AllowUsers AllowGroups;

        AllowUsersString = ''[ ${concatStringsSep ", " AllowUsers} ]'';
        AllowGroupsString = ''[ ${concatStringsSep ", " AllowGroups} ]'';

        forgejo = config.users.users.${cfg.user};

        allowedUser = pipe ([ forgejo.name ]) [
          (map (u: elem u (if AllowUsers == null then [ forgejo.name ] else AllowUsers)))
          (any (belongs: belongs))
        ];
        allowedGroup = pipe ([ forgejo.group ] ++ forgejo.extraGroups) [
          (map (g: elem g (if AllowGroups == null then [ forgejo.group ] else AllowGroups)))
          (any (belongs: belongs))
        ];
      in
      [
        (mkIf (
          !allowedUser
        ) ''Forgejo user "${forgejo.name}" is not allowed in ssh AllowUsers: ${AllowUsersString}'')
        (mkIf (
          !allowedGroup
        ) ''Forgejo group "${forgejo.group}" is not allowed in ssh AllowGroups: ${AllowGroupsString}'')
      ];
    services.forgejo = {
      lfs.enable = true;

      settings = {
        server = {
          HTTP_PORT = cfg.reverse-proxy.port.internal;
          ROOT_URL = "https://${cfg.subdomain}.${config.server.domain}:${toString cfg.reverse-proxy.port.external}";
          SSH_PORT = head config.services.openssh.ports;
        };
        # domain = config.server.domain;
        # session.COOKIE_SECURE = true;
      };
    };

    services = {
      openssh.settings.AcceptEnv = "GIT_PROTOCOL";

      caddy.virtualHosts = genVirtualHosts {
        inherit (cfg) subdomain reverse-proxy;
      };
    };

    users = {
      groups.ssh-users = { };
      users.${cfg.user}.extraGroups = [ "ssh-users" ];
    };

    programs.rust-motd.settings.service_status.Forgejo = "forgejo";
  };
}
