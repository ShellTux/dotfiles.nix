{
  lib,
  lib',
  config,
  ...
}:
let
  inherit (builtins)
    any
    concatStringsSep
    filter
    listToAttrs
    mapAttrs
    ;
  inherit (lib)
    filterAttrs
    groupBy
    mkIf
    pipe
    ;
  inherit (lib'.flake.caddy)
    mkLocalSubdomainProxy
    mkLocalSubpathHandle
    mkPortProxy
    mkSubdomainProxy
    mkSubpathHandle
    ;

  cfg = config.services.caddy;
in
{
  services.caddy = mkIf (cfg.enable && !cfg.disableModule) {
    virtualHosts =
      # VirtualHosts fullLocalFqdn groupBy localFqdn
      pipe cfg.proxies [
        (filter (proxy: proxy.enable))
        (filter (proxy: proxy.host.fullLocalFqdn != null))
        (groupBy (proxy: proxy.host.localFqdn))
        (mapAttrs (
          _: proxies:
          pipe proxies [
            (map mkLocalSubpathHandle)
            (concatStringsSep "\n")
            (
              extraConfig:
              ''
                import tls-local
                encode zstd gzip
              ''
              + extraConfig
            )
            (extraConfig: { inherit extraConfig; })
          ]
        ))
      ]
      # VirtualHosts fullLocalFqdn
      // pipe cfg.proxies [
        (filter (proxy: proxy.enable))
        (filter (proxy: proxy.host.fullLocalFqdn != null))
        (map (proxy: {
          name = proxy.host.fullLocalFqdn;
          value.extraConfig = mkLocalSubdomainProxy proxy;
        }))
        listToAttrs
      ]
      # VirtualHosts fullFqdn groupBy fqdn
      // pipe cfg.proxies [
        (filter (proxy: proxy.enable))
        (filter (proxy: proxy.host.fullFqdn != null))
        (groupBy (proxy: proxy.host.fqdn))
        (filterAttrs (
          _: proxies:
          pipe proxies [
            (map (proxy: proxy.access.isPublic))
            (any (isPublic: isPublic))
          ]
        ))
        (mapAttrs (
          _: proxies:
          pipe proxies [
            (filter (proxy: proxy.access.isPublic))
            (map mkSubpathHandle)
            (concatStringsSep "\n")
            (extraConfig: { inherit extraConfig; })
          ]
        ))
      ]
      # VirtualHosts fullFqdn
      // pipe cfg.proxies [
        (filter (proxy: proxy.enable))
        (filter (proxy: proxy.host.fullFqdn != null))
        (filter (proxy: proxy.access.isPublic))
        (map (proxy: {
          name = proxy.host.fullFqdn;
          value.extraConfig = mkSubdomainProxy proxy;
        }))
        listToAttrs
      ]
      # Expose Ports
      // pipe cfg.proxies [
        (filter (proxy: proxy.enable))
        (filter (proxy: proxy.host.port != null))
        (map (proxy: {
          name = proxy.computedHostPort;
          value.extraConfig = mkPortProxy proxy;
        }))
        listToAttrs
      ]
      // { };
  };
}
