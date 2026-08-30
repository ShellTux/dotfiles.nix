{ lib, ... }:
let
  inherit (builtins) attrNames concatLists elem;
  inherit (lib)
    mkOption
    pipe
    unique
    optionalAttrs
    optionalString
    ;
  inherit (lib.strings) toSentenceCase;
  inherit (lib.types)
    bool
    enum
    listOf
    nullOr
    port
    str
    submodule
    ;

  zoneRegistry = {
    internal = [
      "127.0.0.1/32"
      "::1/128"
    ];
    lan = [
      "10.0.0.0/8"
      "172.16.0.0/12"
      "192.168.0.0/16"
    ];
    wireguard = [ "10.100.0.0/24" ];
    internet = [
      "0.0.0.0/0"
      "::/0"
    ];
  };

  mkEnableOption =
    description:
    mkOption {
      type = bool;
      default = false;
      example = true;
      inherit description;
    };

  mkProxyModule =
    {
      naming,
      name ? null,
      host ? { },
      upstream ? { },
      authelia ? { },
    }:
    let
      defaultAutheliaBackendHost = authelia.backend.host or null;
      defaultAutheliaBackendPort = authelia.backend.port or 9091;
      defaultUpstreamPort = upstream.port or null;
      defaultUpstreamHost = upstream.host or null;

      inherit (naming)
        domain
        hostName
        localDomain
        localHostName
        ;
    in
    submodule (
      { config, ... }:
      {
        options = {

          enable = mkEnableOption "Wether to enable this proxy";

          # --- 1. HOST / ROUTING CONFIGURATION ---
          # Instead of fighting over domain vs subdomain, we use a clean 'host' naming convention.

          host = {

            subdomain = mkOption {
              type = nullOr str;
              default = name;
              example = "grafana";
              description = "";
            };

            localName = mkOption {
              type = nullOr str;
              default = localHostName;
              example = "nas-local";
              description = "The specific hostname assigned to this machine for internal network identification. Defaults to the global system hostname.";
            };

            name = mkOption {
              type = nullOr str;
              default = hostName;
              example = "webserver";
              description = "The primary hostname of the server, used to construct the public FQDN and identity.";
            };

            localDomain = mkOption {
              type = nullOr str;
              default = localDomain;
              example = "example.com";
              description = "The top-level domain or suffix used for internal network routing, such as a home lab or local LAN.";
            };

            domain = mkOption {
              type = nullOr str;
              default = domain;
              example = "example.com";
              description = "The root domain name used to access services from the public internet. If set to null, external public routing and reverse proxy features will remain disabled.";
            };

            path = mkOption {
              type = nullOr str;
              default = config.host.subdomain;
              example = "a/b/c";
              description = "Optional subpath prefix. Leave null to route the root (/) path.";
            };

            rootRedir = mkOption {
              description = "Wether to redir to this proxy on /";
              type = bool;
              default = host.rootRedir or false;
            };

            port = mkOption {
              type = nullOr port;
              example = 8008;
              default = null;
              description = "Optional port to expose.";
            };

            localFqdn = mkOption {
              type = nullOr str;
              description = "The fully qualified domain name for the local network, automatically computed by combining localHostName and localDomain.";
              internal = true;
              default =
                if config.host.localName != null && config.host.localDomain != null then
                  "${config.host.localName}.${config.host.localDomain}"
                else
                  null;
            };

            fullLocalFqdn = mkOption {
              type = nullOr str;
              description = "The comprehensive local address, combining the service subdomain with the system's local FQDN.";
              internal = true;
              default =
                if config.host.subdomain != null && config.host.localFqdn != null then
                  "${config.host.subdomain}.${config.host.localFqdn}"
                else
                  null;
            };

            fqdn = mkOption {
              type = nullOr str;
              description = "The public fully qualified domain name, automatically computed by combining hostName and domain. Evaluates to null if no public domain is specified.";
              internal = true;
              default =
                if config.host.name != null && config.host.domain != null then
                  "${config.host.name}.${config.host.domain}"
                else
                  null;
            };

            fullFqdn = mkOption {
              type = nullOr str;
              description = "The final public-facing endpoint address, combining the service subdomain with the system's public FQDN.";
              internal = true;
              default =
                if config.host.subdomain != null && config.host.fqdn != null then
                  "${config.host.subdomain}.${config.host.fqdn}"
                else
                  null;
            };
          };

          computedHostPort = mkOption {
            type = nullOr str;
            internal = true;
            default =
              if config.host.port == null then null else "${config.host.localFqdn}:${toString config.host.port}";
          };

          computedFqdn = mkOption {
            type = str;
            internal = true;
            default = if config.access.isPublic then config.host.fullFqdn else config.host.fullLocalFqdn;
          };

          computedHref = mkOption {
            type = str;
            internal = true;
            default =
              if config.access.isPublic then
                "https://${config.host.fullFqdn}"
              else
                "https://${config.host.fullLocalFqdn}";
          };

          # --- 2. BACKEND / UPSTREAM CONFIGURATION ---
          # "upstream" or "backend" is the universal industry standard for what sits behind a proxy.

          upstream = {
            host = mkOption (
              {
                type = str;
                default = "127.0.0.1";
                example = "localhost";
                description = "The target address of the local service.";
              }
              // optionalAttrs (defaultUpstreamHost != null) { default = defaultUpstreamHost; }
            );

            port = mkOption (
              {
                type = port;
                description = "The port the local service is listening on.";
                example = 9876;
              }
              // optionalAttrs (defaultUpstreamPort != null) { default = defaultUpstreamPort; }
            );

          };

          computedUpstreamUrl = mkOption {
            type = str;
            internal = true;
            default = "${config.upstream.host}:${toString config.upstream.port}";
          };

          # --- 3. SECURITY & ACCESS CONTROL ---

          access = {
            zones = mkOption {
              type = pipe zoneRegistry [
                attrNames
                enum
                listOf
              ];

              default = [ "internal" ];
              example = [
                "internal"
                "lan"
                "wireguard"
                "internet"
              ];
              description = "Shorthand to allow access from predefined network zones.";
            };

            allowedIps = mkOption {
              type = listOf str;
              default = [ ];
              example = [
                "10.0.0.0/8"
                "192.168.1.50"
              ];
              description = "Explicit list of additional IP addresses or CIDR blocks allowed to access this proxy.";
            };

            computedAllowedIps = mkOption {
              type = listOf str;
              internal = true;
              default = pipe config.access.zones [
                (map (zone: zoneRegistry.${zone}))
                concatLists
                (ips: ips ++ config.access.allowedIps)
                unique
              ];
              description = "The absolute list of allowed IPs gathered from both zones and custom rules.";
            };

            isPublic = mkOption {
              type = bool;
              internal = true;
              default = elem "internet" config.access.zones;
              description = "Whether this proxy is exposed to the public internet.";
            };
          };

          # --- 4. AUTHENTICATION (AUTHELIA) ---

          authelia = {
            enable = mkEnableOption "Authelia portal protection for this proxy route";

            backend = {
              host = mkOption (
                {
                  type = str;
                  default = "127.0.0.1";
                  example = "localhost";
                  description = "The target address of the authelia service.";
                }
                // optionalAttrs (defaultAutheliaBackendHost != null) { default = defaultAutheliaBackendHost; }
              );

              port = mkOption (
                {
                  type = port;
                  description = "The port the local service is listening on.";
                  example = 9876;
                }
                // optionalAttrs (defaultAutheliaBackendPort != null) { default = defaultAutheliaBackendPort; }
              );
            };
            # backendUrl = mkOption {
            #   type = str;
            #   default = "http://127.0.0.1:9091";
            #   description = "The internal network address where the Authelia API is listening.";
            # };

            # Instead of asking for a duplicate subdomain/domain, just ask for the external auth URL
            # or dynamically build it if you can assume it uses the same baseDomain.
            portalUrl = mkOption {
              type = str;
              default =
                if config.host.domain != null then
                  "https://auth.${config.host.domain}"
                else
                  "https://auth.${config.host.name}";
              description = "The external public-facing portal URL where unauthenticated traffic will be redirected to sign in.";
            };

            requiredPolicy = mkOption {
              type = enum [
                "one_factor"
                "two_factor"
              ];
              default = "two_factor";
              description = "The authentication level required to pass this proxy.";
            };
          };

          computedAutheliaBackendUrl = mkOption {
            type = str;
            internal = true;
            default = "${config.authelia.backend.host}:${toString config.authelia.backend.port}";
          };

          # --- 5. Homepage ---

          homepage-dashboard = {
            href = mkOption {
              type = str;
              internal = true;
              default = config.computedHref;
            };

            ping = mkOption {
              type = str;
              internal = true;
              default = config.computedFqdn;
            };

            siteMonitor = mkOption {
              type = str;
              internal = true;
              default = "http://${config.computedUpstreamUrl}";
            };

            widget = {
              url = mkOption {
                type = str;
                internal = true;
                default = config.homepage-dashboard.href;
              };
            };
          };
        };
      }
    );

  mkProxy =
    isLocal: proxy:
    let
      isPublic = !isLocal;
    in
    optionalString (isPublic && proxy.authelia.enable) ''
      import protected-endpoint ${proxy.computedAutheliaBackendUrl}
    ''
    + optionalString isLocal ''
      import subdomain-local ${proxy.computedUpstreamUrl}
    ''
    + optionalString isPublic ''
      import subdomain-public ${proxy.computedUpstreamUrl}
    '';

  mkSubpath =
    isLocal: proxy:
    let
      inherit (proxy.host) path;

      isPublic = !isLocal;

      name = if isLocal then "${path}-local-root" else "${path}-public-root";
      rootRedir = optionalString proxy.host.rootRedir ''
        @${name} path /
        redir @${name} ${proxy.computedHref}{uri}
      '';
    in
    if isPublic && proxy.authelia.enable then
      ''
        ${rootRedir}
        import subpath-public ${path} ${proxy.computedAutheliaBackendUrl} ${proxy.computedUpstreamUrl}
      ''
    else
      ''
        ${rootRedir}
        import subpath-local ${path} ${proxy.computedUpstreamUrl}
      '';
in
{
  mkProxyOption =
    args@{
      description ? null,
      ...
    }:
    mkOption {
      description =
        if description != null then
          description
        else
          "Reverse proxy configuration for the ${toSentenceCase args.name} service.";
      type = mkProxyModule (removeAttrs args [ "description" ]);
    };

  mkProxiesOption =
    {
      naming,
      description ? "List of services to automatically reverse proxy via Caddy.",
      default ? [ ],
    }:
    mkOption {
      inherit description default;
      type = pipe { inherit naming; } [
        mkProxyModule
        listOf
      ];
    };

  mkLocalSubdomainProxy = mkProxy true;
  mkSubdomainProxy = mkProxy false;

  mkLocalSubpathHandle = mkSubpath true;
  mkSubpathHandle = mkSubpath false;

  mkPortProxy =
    proxy:
    let
      blocked_tag = "blocked_${toString proxy.host.port}";
      allowed-ranges = "private_ranges";
    in
    ''
      encode zstd gzip
      import tls-local
      reverse_proxy ${proxy.computedUpstreamUrl}

      @${blocked_tag} not remote_ip ${allowed-ranges}

      header @${blocked_tag} Content-Type "text/html"

      respond @${blocked_tag} 403 {
          import blocked-html
      }
    '';
}
