{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (builtins) concatStringsSep;
  inherit (lib)
    escapeShellArg
    getExe
    getExe'
    mkEnableOption
    mkIf
    mkOption
    pipe
    ;
  inherit (lib.types)
    bool
    enum
    listOf
    package
    str
    ;

  ipset = getExe pkgs.ipset;
  iptables = getExe pkgs.iptables;
  curl = getExe pkgs.curl;
  echo = getExe' pkgs.coreutils "echo";

  ipsetName = escapeShellArg cfg.ipsetName;

  cfg = config.services.geoip-blocking;
in
{
  options.services.geoip-blocking = {
    enable = mkEnableOption "GeoIP firewall";

    disableModule = mkOption {
      description = "Whether to disable this module configuration";
      type = bool;
      default = false;
    };

    mode = mkOption {
      type = enum [
        "allow"
        "deny"
      ];

      default = "allow";
    };

    countries = mkOption {
      type = listOf (enum [
        "PT"
        "ES"
        "FR"
        "DE"
        "GB"
        "IT"
        "NL"
        "BE"
        "US"
        "CA"
      ]);

      default = [ ];

      description = ''
        ISO-3166 country codes allowed through the firewall.
      '';
    };

    updateInterval = mkOption {
      type = str;
      default = "daily";
      example = "hourly";
    };

    ipsetName = mkOption {
      type = str;
      default = "geoip-countries";
    };

    countriesFile = mkOption {
      internal = true;
      type = package;
      default = pipe cfg.countries [
        (concatStringsSep "\n")
        (pkgs.writeText "geoip-blocking.countries.txt")
      ];
    };
  };

  config = mkIf (cfg.enable && !cfg.disableModule) {
    services.geoip-blocking = { };

    environment.systemPackages = [
      pkgs.curl
      pkgs.ipset
      pkgs.iptables
    ];

    systemd = {
      services.geoip-blocking-update = {
        description = "Update GeoIP IP sets";

        path = [
          pkgs.curl
          pkgs.ipset
          pkgs.iptables
          pkgs.gnugrep
          pkgs.gawk
          pkgs.coreutils
        ];

        serviceConfig = {
          Type = "oneshot";
        };

        script = ''
          set -euo pipefail

          ${ipset} create -exist "${ipsetName}" hash:net family inet
          ${ipset} flush "${ipsetName}"

          while read COUNTRY; do
            [ -z "$COUNTRY" ] && continue

            URL="https://www.ipdeny.com/ipblocks/data/countries/$(echo "$COUNTRY" | tr '[:upper:]' '[:lower:]').zone"

            ${echo} "Downloading $COUNTRY..."

            ${curl} -fsSL "$URL" | while read -r cidr
            do
              ${ipset} add -exist "${ipsetName}" "$cidr"
            done

          done < ${cfg.countriesFile}

          if [ "${cfg.mode}" = "deny" ]
          then

            ${iptables} \
              -C INPUT \
              -m set --match-set "${ipsetName}" src \
              -j DROP 2>/dev/null || \
            ${iptables} \
              -I INPUT \
              -m set --match-set "${ipsetName}" src \
              -j DROP

          else

            ${iptables} \
              -C INPUT \
              -m set --match-set "${ipsetName}" src \
              -j ACCEPT 2>/dev/null || \
            ${iptables} \
              -I INPUT \
              -m set --match-set "${ipsetName}" src \
              -j ACCEPT

            ${iptables} -C INPUT -j DROP 2>/dev/null || \
            ${iptables} -A INPUT -j DROP

          fi
        '';

        wantedBy = [
          "multi-user.target"
        ];
      };

      timers.geoip-blocking-update = {
        wantedBy = [ "timers.target" ];

        timerConfig = {
          OnBootSec = "5min";
          OnUnitActiveSec = cfg.updateInterval;
          Persistent = true;
        };
      };
    };

  };
}
