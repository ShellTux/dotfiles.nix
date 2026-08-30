{ config, ... }:
let
  inherit (config.sops) secrets;
in
{
  services.duckdns = {
    domainsFile = secrets."services/duckdns/domainsFile".path;
    tokenFile = secrets."services/duckdns/tokenFile".path;
  };

  sops.secrets = {
    "services/duckdns/domainsFile" = { };
    "services/duckdns/tokenFile" = { };
  };
}
