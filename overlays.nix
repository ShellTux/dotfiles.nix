{ ... }:
final: prev:
let
  inherit (prev.lib) mapAttrs;

  chrome-extensions = mapAttrs (extension: id: { inherit id; }) {
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
    zotero-connector = "ekhagklcjbdpajgpjgmbionohlpdbjgc";
  };
in
{
  ncmpcpp = prev.ncmpcpp.override {
    clockSupport = true;
    visualizerSupport = true;
  };

  OVMF = prev.OVMF.override {
    secureBoot = true;
    tpmSupport = true;
  };

  rofi = prev.rofi.override {
    plugins = [ prev.rofi-emoji ];
  };

  prismlauncher = prev.prismlauncher.override {
    jdks =
      let
        inherit (prev.javaPackages.compiler) temurin-bin;
      in
      [
        temurin-bin.jdk-8
        temurin-bin.jdk-17
        temurin-bin.jdk-21
      ];
  };

  parallel-full = prev.parallel-full.override {
    willCite = true;
  };

  brave = prev.brave // {
    extensions = prev.lib.recursiveUpdate (prev.brave.extensions or { }) chrome-extensions;
  };

}
