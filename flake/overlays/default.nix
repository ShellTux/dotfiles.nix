{ inputs, withSystem, ... }:
{
  imports = [
    inputs.flake-parts.flakeModules.easyOverlay
  ];

  flake.overlays = {
    laptop =
      final: prev:
      withSystem prev.stdenv.hostPlatform.system (
        { ... }:
        {
          OVMF = prev.OVMF.override {
            secureBoot = true;
            tpmSupport = true;
            qemu = true;
          };
        }
      );
  };

  perSystem =
    {
      config,
      pkgs,
      final,
      ...
    }:
    {
      imports = [
        ./brave
      ];

      overlayAttrs = {
        ncmpcpp = pkgs.ncmpcpp.override {
          clockSupport = true;
          visualizerSupport = true;
        };

        parallel-full = pkgs.parallel-full.override {
          willCite = true;
        };

        prismlauncher = pkgs.prismlauncher.override {
          jdks =
            let
              inherit (pkgs.javaPackages.compiler) temurin-bin;
            in
            [
              temurin-bin.jdk-8
              temurin-bin.jdk-17
              temurin-bin.jdk-21
            ];
        };

        terminals = {
          inherit (pkgs)
            alacritty
            cool-retro-term
            foot
            ghostty
            gnome-terminal
            kitty
            lxterminal
            st
            wezterm
            xfce4-terminal
            xterm
            ;
          inherit (pkgs.kdePackages) konsole;
        };

        browsers = {
          inherit (pkgs)
            brave
            chromium
            firefox
            librewolf
            qutebrowser
            tor-browser
            ;
        };
      };

      packages = {
        inherit (config.overlayAttrs) parallel-full ncmpcpp;
      };
    };
}
