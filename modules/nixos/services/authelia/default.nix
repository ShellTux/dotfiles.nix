{
  config,
  lib,
  lib',
  ...
}:
let
  inherit (builtins)
    attrNames
    attrValues
    elem
    elemAt
    fromJSON
    length
    listToAttrs
    mapAttrs
    match
    ;
  inherit (lib)
    flatten
    mapAttrs'
    mkDefault
    mkIf
    mkOption
    nameValuePair
    pipe
    ;
  inherit (lib.types) bool;
  inherit (lib'.flake.networking) mkSiteOptions;
  inherit (config.networking) fqdnOrHostName domain;

  autheliaSecret = secret: config.sops.secrets."services/authelia/${fqdnOrHostName}/${secret}".path;
  autheliaPort = pipe cfg.instances."${fqdnOrHostName}".settings.server.address [
    (match "tcp://:([0-9]+)/")
    (matches: elemAt matches 0)
    fromJSON
  ];

  cfg = config.services.authelia;
in
{
  options.services.authelia = {
    enabled = mkOption {
      internal = true;
      type = bool;
      default = pipe cfg.instances [
        attrNames
        length
        (length: length > 0)
      ];
      description = "Internal value to access if there is more than 0 instances";
    };

    disableModule = mkOption {
      description = "Whether to disable this module configuration";
      type = bool;
      default = false;
    };

    site = mkSiteOptions {
      subdomain = "auth";
      inherit (config.networking) fqdnOrHostName localFqdn;
      description = "Authelia";
    };
  };

  config = mkIf (!cfg.disableModule) {
    services.authelia = {
      instances."${fqdnOrHostName}" =
        let
          name = cfg.instances."${fqdnOrHostName}".name;
        in
        mkIf (domain != null) {
          enable = mkDefault true;
          settings = {
            theme = "auto";
            default_2fa_method = "totp";
            log.level = "debug"; # TODO: file_path
            server = {
              disable_healthcheck = true;
              endpoints.authz.forward-auth.implementation = "ForwardAuth";
            };

            session.cookies = [
              {
                domain = fqdnOrHostName;
                authelia_url = "https://${cfg.site.domain}";
              }
            ];

            access_control = {
              default_policy = "deny";
              rules = [
                {
                  inherit (cfg.site) domain;
                  policy = "bypass";
                }
              ];
            };
            storage.local.path = "/var/lib/authelia-${name}/db.sqlite";
            notifier.filesystem.filename = "/var/lib/authelia-${name}/notifications.yml";
            authentication_backend.file.path = autheliaSecret "authentication_backend/file/users.yaml";
          };

          secrets = {
            jwtSecretFile = autheliaSecret "jwtSecretFile";
            oidcHmacSecretFile = autheliaSecret "oidc/hmacSecretFile";
            oidcIssuerPrivateKeyFile = autheliaSecret "oidc/issuerPrivateKeyFile";
            sessionSecretFile = autheliaSecret "sessionSecretFile";
            storageEncryptionKeyFile = autheliaSecret "storageEncryptionKeyFile";
          };

        };
    };

    services.caddy = {
      snippets.authelia = mkDefault ''
        forward_auth 127.0.0.1:${toString autheliaPort} {
          uri /api/authz/forward-auth
          {block}
          copy_headers Remote-User Remote-Groups Remote-Email Remote-Name
        }
      '';

      virtualHosts = mkIf (cfg.site.reverse-proxy == "caddy") {
        "${cfg.site.fqdn}" = mkIf (elem "public" cfg.site.exposure) {
          extraConfig = ''
            import tls-public
            import encoding
            import coraza
            import reverse-proxy 127.0.0.1:${toString autheliaPort}
          '';
        };

        "${cfg.site.localFqdn}" = mkIf (elem "local" cfg.site.exposure) {
          extraConfig = ''
            import tls-local
            import encoding
            import reverse-proxy 127.0.0.1:${toString autheliaPort}
          '';
        };
      };
    };

    programs.rust-motd.settings.service_status = mapAttrs' (
      _: { name, user, ... }: nameValuePair "Authelia ${name}" user
    ) cfg.instances;

    sops.secrets = pipe config.services.authelia.instances [
      (mapAttrs (
        _: instance: {
          inherit (instance) user group;
          fqdn = fqdnOrHostName;
        }
      ))
      (mapAttrs (
        _:
        {
          user,
          group,
          fqdn,
        }:
        let
          autheliaOpts = {
            owner = user;
            inherit group;
            restartUnits = [
              config.systemd.services.caddy.name
              "${user}.service"
            ];
          };
        in
        [
          (nameValuePair "services/authelia/${fqdn}/authentication_backend/file/users.yaml" autheliaOpts)
          (nameValuePair "services/authelia/${fqdn}/jwtSecretFile" autheliaOpts)
          (nameValuePair "services/authelia/${fqdn}/oidc/hmacSecretFile" autheliaOpts)
          (nameValuePair "services/authelia/${fqdn}/oidc/issuerPrivateKeyFile" autheliaOpts)
          (nameValuePair "services/authelia/${fqdn}/sessionSecretFile" autheliaOpts)
          (nameValuePair "services/authelia/${fqdn}/storageEncryptionKeyFile" autheliaOpts)
        ]
      ))
      attrValues
      flatten
      listToAttrs
    ];
  };
}
