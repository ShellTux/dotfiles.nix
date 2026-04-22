{ ... }:
{
  genVirtualHosts =
    {
      subdomain,
      reverse-proxy, # AttrSet { .port = { external, internal }; }
    }:
    let
      inherit (reverse-proxy.port) external internal;
    in
    {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString internal}";
      };
    };
}
