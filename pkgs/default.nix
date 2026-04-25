{ ... }:
{
  perSystem =
    {
      inputs',
      pkgs,
      system,
      ...
    }:
    let
      inherit (pkgs) callPackage;

      nixvim' = inputs'.nixvim.legacyPackages;

      nixvimModule = {
        inherit pkgs system;
        module = import ./nixvim;
        extraSpecialArgs = {
          inherit pkgs;
          leader-key = " ";
          noice.enable = true;
        };
      };
    in
    {
      packages = rec {
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
        mounts = callPackage ./mounts { };
        mpd-notification = callPackage ./mpd-notification { inherit notify-music; };
        nix-out-paths = callPackage ./nix-out-paths { };
        nixvim = nixvim'.makeNixvimWithModule nixvimModule;
        notify-music = callPackage ./notify-music { inherit fetch-music-data; };
        open = callPackage ./open { };
        prismlauncher = callPackage ./prismlauncher { };
        repl = callPackage ./repl { };
        sddm-lain-wired-theme = callPackage ./sddm-lain-wired-theme { };
        stay = callPackage ./stay { };
        swap = callPackage ./swap { };
        umounts = callPackage ./umounts { };
        vman = callPackage ./vman { };
        vm = callPackage ./vm { };
        volume = callPackage ./volume { };
        walld = callPackage ./walld { };
        wclip = callPackage ./wclip { };
        wg-conf = callPackage ./wg-conf { };
      };
    };
}
