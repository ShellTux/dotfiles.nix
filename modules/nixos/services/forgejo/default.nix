{
  config,
  lib,
  lib',
  ...
}:
let
  inherit (builtins) elem concatStringsSep any;
  inherit (lib)
    mkIf
    mkOption
    pipe
    mkDefault
    optional
    removeSuffix
    ;
  inherit (lib.types) bool;
  inherit (lib'.flake.caddy) mkProxyOption;

  inherit (cfg.proxy.host) fqdn;

  cfg = config.services.forgejo;
in
{
  options.services.forgejo = {
    disableModule = mkOption {
      description = "Whether to disable this module configuration";
      type = bool;
      default = false;
    };

    proxy = mkProxyOption {
      inherit (config.networking) naming;
      name = "forgejo";
      upstream.port = cfg.settings.server.HTTP_PORT;
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
            ROOT_URL = cfg.proxy.homepage-dashboard.href;
            #   SSH_PORT = head config.services.openssh.ports;
          };

          other = {
            SHOW_FOOTER_VERSION = mkDefault true;
          };
        };

        proxy.authelia.settings.access_control.rules = [
          {
            resources = [
              "^.*\\.git.*$"
              "^/info/refs.*$"
              "^/git-upload-pack.*$"
              "^/git-receive-pack.*$"
            ];

            policy = "bypass";
          }
        ];
      };

      openssh.settings.AcceptEnv = [ "GIT_PROTOCOL" ];

      caddy.proxies = optional cfg.proxy.enable cfg.proxy;

      authelia.instances."${fqdn}".settings.identity_providers.oidc.clients = [
        {
          client_id = "forgejo";
          client_name = "Forgejo";

          client_secret = ''{{ secret "${
            config.sops.secrets."services/authelia/${fqdn}/oidc/clients/forgejo/client_secret".path
          }" }}'';

          authorization_policy = "one_factor";

          redirect_uris = [
            "${cfg.proxy.computedHref}/user/oauth2/authelia/callback"
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

    users = {
      groups.ssh-users = { };
      users.${cfg.user}.extraGroups = [ "ssh-users" ];
    };

    programs.rust-motd.settings.service_status.Forgejo =
      removeSuffix ".service" config.systemd.services.forgejo.name;

    sops.secrets."services/authelia/${fqdn}/oidc/clients/forgejo/client_secret" = {
      owner = config.services.authelia.instances."${fqdn}".user;
      group = config.services.authelia.instances."${fqdn}".group;
      mode = "0400";
      reloadUnits = [ config.systemd.services.forgejo.name ];
    };
  };
}
