{
  inputs,
  config,
  lib,
  pkgs,
  system,
  ...
}:
let
  inherit (lib) mkOption mkIf mkDefault;
  inherit (lib.types) bool;
  inherit (config.home) username;

  fa = inputs.firefox-addons.packages.${system};

  cfg = config.programs.floorp;
in
{
  options.programs.floorp = {
    disableModule = mkOption {
      description = "Whether to disable this module configuration";
      type = bool;
      default = false;
    };
  };

  config = {
    programs.floorp = mkIf (cfg.enable && !cfg.disableModule) {
      languagePacks = mkDefault [
        "pt-PT"
        "en-US"
      ];

      profiles = {
        ${username} = {
          name = "${username}";
          isDefault = true;

          extensions.packages = [
            fa.augmented-steam
            fa.bitwarden
            fa.darkreader
            fa.dearrow
            fa.ff2mpv
            fa.material-icons-for-github
            fa.protondb-for-steam
            fa.return-youtube-dislikes
            fa.search-by-image
            fa.sponsorblock
            fa.tridactyl
            fa.ublock-origin
            fa.vimium
            fa.xbrowsersync
          ];

          settings = {
            "general.autoScroll" = true;
            "mousewheel.default.delta_multiplier_y" = 100;
            "widget.disable-workspace-management" = true;
            "intl.accept_languages" = "pt-PT, en-US, en";
          };

          search =
            let
              Bing = "bing";
              DuckDuckGo = "ddg";
              Ecosia = "ecosia";
              Google = "google";
              Qwant = "qwant";
              Searx = "searx";
              Startpage = "startpage";
              Wikipedia = "wikipedia";
            in
            {
              force = true;
              default = "unduck";
              order = [
                DuckDuckGo
                Startpage
                Google
                Searx
                "Google Académico"
                "Swiss cows"
                "Brave Search"
                Qwant
                "Gigablast"
                "Qmamu"
                Ecosia
              ];
              engines = {
                "Home Manager Options" = {
                  urls = [
                    { template = "https://home-manager-options.extranix.com/?query={searchTerms}&release=master"; }
                  ];
                  icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
                  definedAliases = [
                    "!hm"
                    "!hmo"
                    "@hmo"
                  ];
                };

                GitHub = {
                  urls = [ { template = "https://github.com/search?q={searchTerms}"; } ];
                  icon = "https://github.com/fluidicon.png";
                  updateInterval = 7 * 24 * 60 * 60 * 1000;
                  definedAliases = [
                    "!git"
                    "@git"
                    "@gh"
                    "!github"
                    "@github"
                  ];
                };

                ${Wikipedia}.metaData.alias = "!wiki";
                ${Google}.metaData = {
                  hidden = true;
                  alias = "!g";
                };

                "Nix Packages" = {
                  urls = [
                    {
                      template = "https://search.nixos.org/packages?query={searchTerms}&type=packages";
                    }
                  ];

                  icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
                  definedAliases = [
                    "!np"
                    "!nix"
                    "@nix"
                    "!np"
                    "@np"
                    "!nixpackages"
                    "@nixpackages"
                  ];
                };

                "NixOS Wiki" = {
                  urls = [ { template = "https://wiki.nixos.org/index.php?search={searchTerms}"; } ];
                  icon = "https://wiki.nixos.org/favicon.png";
                  updateInterval = 24 * 60 * 60 * 1000; # every day
                  definedAliases = [
                    "!nixos"
                    "@nixos"
                    "@nw"
                  ];
                };

                ${Bing}.metaData.hidden = true;

                unduck = {
                  name = "Unduck";
                  urls = [ { template = "https://unduck.link?q={searchTerms}"; } ];
                  icon = "https://unduck.link/search.svg";
                  updateInterval = 24 * 60 * 60 * 1000; # every day
                  definedAliases = [ "ud" ];
                };
              };
            };
        };
      };
    };

    stylix.targets.floorp.profileNames = [ "${username}" ];

    wayland.windowManager.hyprland.settings.windowrule = [
      "float, title:^Extension:.*- Bitwarden — (Ablaze Floorp|Firefox)$"
      "idleinhibit, fullscreen, class:firefox(-developer-edition)?"
      "opaque, title:^(Vídeo em janela flutuante|Picture-in-Picture)$"
      "pin, title:^(Vídeo em janela flutuante|Picture-in-Picture)$"
    ];
  };
}
