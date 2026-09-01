{
  lib,
  lib',
  config,
  ...
}:
let
  inherit (builtins)
    any
    attrValues
    filter
    head
    listToAttrs
    mapAttrs
    ;
  inherit (lib)
    filterAttrs
    flatten
    groupBy
    mkIf
    nameValuePair
    pipe
    splitString
    ;
  inherit (lib'.flake.authelia) sortRules;
  inherit (config.services.authelia.proxy.host) subdomain;
  inherit (config.sops) secrets;

  cfg = config.services.caddy;
in
{
  config = mkIf (cfg.enable && !cfg.disableModule) {
    services.authelia.instances = pipe cfg.proxies [
      (groupBy (proxy: proxy.host.fqdn))
      (filterAttrs (fqdn: proxies: true))
      (mapAttrs (
        fqdn: proxies:
        let
          enable = pipe proxies [
            (filter (proxy: proxy.host.fqdn == fqdn))
            (map (proxy: proxy.enable && proxy.authelia.enable && proxy.access.isPublic))
            (any (enable: enable))
          ];

          name = pipe fqdn [
            (splitString ".")
            head
          ];
        in
        {
          inherit enable name;

          secrets = {
            jwtSecretFile = secrets."services/authelia/${fqdn}/jwtSecretFile".path;
            sessionSecretFile = secrets."services/authelia/${fqdn}/sessionSecretFile".path;
            storageEncryptionKeyFile = secrets."services/authelia/${fqdn}/storageEncryptionKeyFile".path;
          };

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
                domain = fqdn;
                authelia_url = "https://${subdomain}.${fqdn}";
                default_redirection_url = "https://www.${fqdn}";
              }
            ];

            access_control = {
              default_policy = "deny";
              rules = [
                {
                  domain = "${subdomain}.${fqdn}";
                  policy = "bypass";
                }
              ]
              ++ pipe proxies [
                (map (proxy: proxy.authelia.settings.access_control.rules))
                (flatten)
                sortRules
                (map (filterAttrs (_: rule: rule != null && rule != [ ])))
              ];
            };
            storage.local.path = "/var/lib/authelia-${name}/db.sqlite";
            notifier.filesystem.filename = "/var/lib/authelia-${name}/notifications.yml";
            authentication_backend.file.path =
              secrets."services/authelia/${fqdn}/authentication_backend/file/users.yaml".path;
          };
        }
      ))
    ];

    sops.secrets = pipe config.services.authelia.instances [
      (mapAttrs (
        _: instance: {
          inherit (instance) user group;
          inherit (config.services.authelia.proxy.host) fqdn;
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
          autheliaService = "${user}.service";
          autheliaOpts = {
            owner = user;
            inherit group;
            restartUnits = [
              "caddy.service"
              autheliaService
            ];
          };
        in
        [
          (nameValuePair "services/authelia/${fqdn}/authentication_backend/file/users.yaml" autheliaOpts)
          (nameValuePair "services/authelia/${fqdn}/jwtSecretFile" autheliaOpts)
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
