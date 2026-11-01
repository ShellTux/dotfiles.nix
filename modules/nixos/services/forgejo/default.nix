{
  config,
  lib,
  lib',
  ...
}:
let
  inherit (builtins)
    any
    concatStringsSep
    elem
    head
    ;
  inherit (lib)
    mkIf
    mkOption
    pipe
    mkDefault
    removeSuffix
    ;
  inherit (lib.types) bool;
  inherit (lib'.flake.networking) mkSiteOptions;

  inherit (config.networking) fqdnOrHostName;

  isPublic = elem "public" cfg.site.exposure;

  cfg = config.services.forgejo;
in
{
  options.services.forgejo = {
    disableModule = mkOption {
      description = "Whether to disable this module configuration";
      type = bool;
      default = false;
    };

    site = mkSiteOptions {
      subdomain = "forgejo";
      description = "Forgejo is a self-hosted lightweight software forge.";
      inherit (config.networking) fqdnOrHostName localFqdn;
    };
  };

  config = mkIf (cfg.enable && !cfg.disableModule) {
    warnings =
      let
        inherit (config.services.openssh.settings) AllowUsers AllowGroups;

        AllowUsersString = "[ ${concatStringsSep ", " AllowUsers} ]";
        AllowGroupsString = "[ ${concatStringsSep ", " AllowGroups} ]";

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

    services = {
      forgejo = {
        lfs.enable = true;

        settings = {
          DEFAULT = {
            APP_SLOGAN = "Este código é uma merda porque foi eu que escrevi";
          };

          service = {
            DISABLE_REGISTRATION = mkDefault true;
            SHOW_REGISTRATION_BUTTON = mkDefault false;
            DEFAULT_KEEP_EMAIL_PRIVATE = mkDefault true;
            VALID_SITE_URL_SCHEMES = mkDefault "https";
          };

          server = {
            DISABLE_SSH = mkIf isPublic false;
            ROOT_URL = cfg.site.href;
            SSH_LISTEN_HOST = mkDefault "0.0.0.0";
            SSH_LISTEN_PORT = mkDefault 2240;
            SSH_PORT = if isPublic then 443 else head config.services.openssh.ports;
            SSH_SERVER_USE_PROXY_PROTOCOL = mkIf isPublic false;
            START_SSH_SERVER = mkIf isPublic true;
          };

          other = {
            SHOW_FOOTER_VERSION = mkDefault true;
          };
        };

      };

      openssh.settings.AcceptEnv = [ "GIT_PROTOCOL" ];

      authelia.instances."${fqdnOrHostName}".settings = {
        access_control.rules = [
          {
            inherit (cfg.site) domain;

            resources = [
              "^.*\\.git.*$"
              "^/info/refs.*$"
              "^/git-upload-pack.*$"
              "^/git-receive-pack.*$"
            ];

            policy = "bypass";
          }
        ];

        identity_providers.oidc.clients = [
          {
            client_id = "forgejo";
            client_name = "Forgejo";

            client_secret = ''{{ secret "${
              config.sops.secrets."services/authelia/${fqdnOrHostName}/oidc/clients/forgejo/client_secret".path
            }" }}'';

            authorization_policy = "one_factor";

            redirect_uris = [
              "${cfg.site.href}/user/oauth2/authelia/callback"
            ];

            scopes = [
              "openid"
              "profile"
              "email"
            ];

            userinfo_signed_response_alg = "none";
            grant_types = [ "authorization_code" ];
            response_types = [ "code" ];
          }
        ];
      };

      caddy = {
        globalConfig = mkIf isPublic ''
          servers {
            listener_wrappers {
              layer4 {
                @forgejo-ssh ssh
                route @forgejo-ssh {
                  proxy 127.0.0.1:${toString cfg.settings.server.SSH_LISTEN_PORT}
                }
                route
              }
              tls
            }
          }
        '';

        virtualHosts = {
          "${cfg.site.fqdn}" = mkIf (elem "public" cfg.site.exposure) {
            extraConfig = ''
              import tls-public
              import encoding
              import coraza
              import reverse-proxy 127.0.0.1:${toString cfg.settings.server.HTTP_PORT}
            '';
          };

          "${cfg.site.localFqdn}" = mkIf (elem "local" cfg.site.exposure) {
            extraConfig = ''
              import tls-local
              import encoding
              import reverse-proxy 127.0.0.1:${toString cfg.settings.server.HTTP_PORT}
            '';
          };
        };
      };

      homepage-dashboard.service-templates.forgejo = {
        display = "Forgejo";
        inherit (cfg.site)
          href
          ping
          siteMonitor
          description
          ;
        icon = "forgejo.png";
        widget = {
          url = cfg.site.href;
          type = "gitea";
          key = "{{HOMEPAGE_VAR_FORGEJO_KEY}}";
          fields = [
            "repositories"
            "notifications"
            "issues"
            "pulls"
          ];
        };
      };
    };

    users = {
      groups.ssh-users = { };
      users.${cfg.user}.extraGroups = [ "ssh-users" ];
    };

    programs.rust-motd.settings.service_status.Forgejo =
      removeSuffix ".service" config.systemd.services.forgejo.name;

    sops.secrets."services/authelia/${fqdnOrHostName}/oidc/clients/forgejo/client_secret" = {
      owner = config.services.authelia.instances."${fqdnOrHostName}".user;
      group = config.services.authelia.instances."${fqdnOrHostName}".group;
      mode = "0400";
      reloadUnits = [ config.systemd.services.forgejo.name ];
    };
  };
}
