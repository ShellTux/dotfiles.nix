{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (builtins) filter;
  inherit (lib)
    mkOption
    mkIf
    mapAttrs
    ;
  inherit (lib.types) bool listOf enum;

  chromium-extensions = mapAttrs (extension: id: { inherit id; }) {
    bitwarden = "nngceckbapebfimnlniiiahkandclblb";
    dark-reader = "eimadpbcbfnmbkopoojfekhnkhdbieeh";
    ff2mpv = "ephjcajbkgplkjmelpglennepbpmdpjg";
    material-icons-for-github = "bggfcpfjbdkhfhfmkjpbhnkhnpjjeomc";
    return-youtube-dislike = "gebbhagfogifgggkldgodflihgfeippi";
    search-by-image = "cnojnbdhbhnkbcieeekonklommdnndci";
    sponsorblock-for-youtube = "mnjggcdmjocbbbhaepdhchncahnbgone";
    ublock-origin = "cjpalhdlnbpafiamejdnhcphjbkeiagm";
    vimium = "dbepggeogbaibhgnhhndojpepiihcmeb";
    xbrowsersync = "lcbjdhceifofjlpecfpeimnnphbcjgnc";
  };

  cfg = config.programs.chromium;
in
{
  options.programs.chromium = {
    disableModule = mkOption {
      description = "Whether to disable this module configuration";
      type = bool;
      default = false;
    };

    flavors = mkOption {
      description = "Which flavors of chromium to enable";
      type = listOf (enum [
        "brave"
        "chromium"
        "google-chrome"
        "google-chrome-beta"
        "google-chrome-dev"
        "ungoogled-chromium"
        "vivaldi"
      ]);
      default = [ ];
    };
  };

  config = {
    programs.chromium = mkIf (cfg.enable && !cfg.disableModule) {
      package = pkgs.brave;

      commandLineArgs = [
        "--ozone-platform-hint=auto"
      ];

      extensions = [
        chromium-extensions.bitwarden
        chromium-extensions.dark-reader
        chromium-extensions.ff2mpv
        chromium-extensions.material-icons-for-github
        chromium-extensions.return-youtube-dislike
        chromium-extensions.search-by-image
        chromium-extensions.sponsorblock-for-youtube
        chromium-extensions.ublock-origin
        chromium-extensions.vimium
        chromium-extensions.xbrowsersync
      ];
    };

    # home.packages = map (
    #   pkg:
    #   pkgs.${pkg}.override {
    #     commandLineArgs = "--ozone-platform-hint=auto";
    #   }
    # ) (filter (pkg: pkg.meta.mainProgram != cfg.package.meta.mainProgram) cfg.flavors);

    wayland.windowManager.hyprland.settings.windowrule = [
      "idleinhibit, focus, class:^(brave)$,title:(.*)(YouTube)(.*)"
      "idleinhibit, fullscreen, class:^(brave)$"
      "float, initialClass:^(brave)$, initialTitle:^(Save File)$"
      "size <50% <50%,initialClass:^(brave)$,initialTitle:^(Save File)$"
      "float,initialClass:^(brave)$,initialTitle:(.*)(wants to save)$"
      "size <50% <50%,initialClass:^(brave)$,initialTitle:(.*)(wants to save)$"
    ];
  };
}
