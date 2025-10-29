{
  perSystem =
    {
      inputs',
      pkgs,
      system,
      ...
    }:
    {
      packages =
        let
          inherit (pkgs) callPackage;

          nixvim' = inputs'.nixvim.legacyPackages;
          nixvimModule = {
            inherit system pkgs;
            module = import ./neovim;
          };
        in
        rec {
          brightness = callPackage ./brightness { };
          create-module = callPackage ./create-module { };
          create-pkg = callPackage ./create-pkg { };
          dotfiles-check = callPackage ./dotfiles-check { };
          fetch-music-data = callPackage ./fetch-music-data { };
          gf = callPackage ./gf { };
          help = callPackage ./help { };
          hyprland-power-saver = callPackage ./hyprland-power-saver { };
          ipa = callPackage ./ipa { };
          mknix = callPackage ./mknix { };
          mktouch = callPackage ./mktouch { };
          mpd-notification = callPackage ./mpd-notification { inherit notify-music; };
          neovim = nixvim'.makeNixvimWithModule nixvimModule;
          nix-out-paths = callPackage ./nix-out-paths { };
          notify-music = callPackage ./notify-music { inherit fetch-music-data; };
          nvim = neovim;
          open = callPackage ./open { };
          prismlauncher = callPackage ./prismlauncher { };
          repl = callPackage ./repl { };
          sddm-lain-wired-theme = callPackage ./sddm-lain-wired-theme { };
          stay = callPackage ./stay { };
          swap = callPackage ./swap { };
          vman = callPackage ./vman { };
          vm = callPackage ./vm { };
          volume = callPackage ./volume { };
          walld = callPackage ./walld { };
          wclip = callPackage ./wclip { };
        };
    };
}
