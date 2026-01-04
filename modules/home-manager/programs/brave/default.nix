{
  config,
  lib,
  flake-lib,
  ...
}:
let
  inherit (lib)
    mkOption
    mkIf
    mapAttrs
    ;
  inherit (lib.types) bool;
  inherit (flake-lib.hyprland.windowrule) idleinhibit float size;

  # TODO: Make this globally accesible to all diferent modules on chromium browsers
  chromium-extensions = mapAttrs (extension: id: { inherit id; }) {
    augmented-steam = "dnhpnfgdlenaccegplpojghhmaamnnfp";
    bitwarden = "nngceckbapebfimnlniiiahkandclblb";
    dark-reader = "eimadpbcbfnmbkopoojfekhnkhdbieeh";
    DeArrow = "enamippconapkdmgfgjchkhakpfinmaj";
    enhancer-for-youtube = "ponfpcnoihfmfllpaingbgckeeldkhle";
    ff2mpv = "ephjcajbkgplkjmelpglennepbpmdpjg";
    material-icons-for-github = "bggfcpfjbdkhfhfmkjpbhnkhnpjjeomc";
    protondb-for-steam = "ngonfifpkpeefnhelnfdkficaiihklid";
    return-youtube-dislike = "gebbhagfogifgggkldgodflihgfeippi";
    search-by-image = "cnojnbdhbhnkbcieeekonklommdnndci";
    sponsorblock-for-youtube = "mnjggcdmjocbbbhaepdhchncahnbgone";
    ublock-origin = "cjpalhdlnbpafiamejdnhcphjbkeiagm";
    vimium = "dbepggeogbaibhgnhhndojpepiihcmeb";
    xbrowsersync = "lcbjdhceifofjlpecfpeimnnphbcjgnc";
  };

  cfg = config.programs.brave;
in
{
  options.programs.brave = {
    disableModule = mkOption {
      description = "Whether to disable this module configuration";
      type = bool;
      default = false;
    };
  };

  config = {
    programs.brave = mkIf (cfg.enable && !cfg.disableModule) {
      commandLineArgs = [
        "--ozone-platform-hint=auto"
      ];

      extensions = [
        chromium-extensions.augmented-steam
        chromium-extensions.bitwarden
        chromium-extensions.dark-reader
        chromium-extensions.DeArrow
        chromium-extensions.enhancer-for-youtube
        chromium-extensions.ff2mpv
        chromium-extensions.material-icons-for-github
        chromium-extensions.protondb-for-steam
        chromium-extensions.return-youtube-dislike
        chromium-extensions.search-by-image
        chromium-extensions.sponsorblock-for-youtube
        chromium-extensions.ublock-origin
        chromium-extensions.vimium
        chromium-extensions.xbrowsersync
      ];
    };

    wayland.windowManager.hyprland.settings.windowrule = [
      (idleinhibit {
        match = "title (.*)(YouTube)(.*)";
        idle_inhibit = "focus";
      })
      (idleinhibit {
        match = "class ^(brave)$";
        idle_inhibit = "fullscreen";
      })
      (float { match = "initial_title ^(Save File)$"; })
      (size {
        match = "initial_title ^(Save File)$";
        width = "<50%";
        height = "<50%";
      })
      (float { match = "initial_title (.*)(wants to save)$"; })
      (size {
        match = "initial_title (.*)(wants to save)$";
        width = "<50%";
        height = "<50%";
      })
    ];
  };
}
