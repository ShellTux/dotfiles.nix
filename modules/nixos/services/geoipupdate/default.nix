{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkOption mkIf mkDefault;
  inherit (lib.types) bool;

  cfg = config.services.geoipupdate;
in
{
  options.services.geoipupdate = {
    disableModule = mkOption {
      description = "Whether to disable this module configuration";
      type = bool;
      default = false;
    };
  };

  config = mkIf (cfg.enable && !cfg.disableModule) {
    services.geoipupdate.settings = {
      DatabaseDirectory = mkDefault "/var/lib/GeoIP";
      LicenseKey = mkDefault { _secret = config.sops.secrets."services/geoipupdate/LicenseKey".path; };
      EditionIDs = mkDefault [
        "GeoLite2-ASN"
        "GeoLite2-City"
        "GeoLite2-Country"
      ];
    };

    sops.secrets."services/geoipupdate/LicenseKey" = { };
  };
}
