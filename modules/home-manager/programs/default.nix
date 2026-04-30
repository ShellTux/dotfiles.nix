{ ... }:
let
  home-manager-program-import =
    path:
    {
      config,
      lib,
      lib',
      ...
    }:
    let
      inherit (lib) mkOption;
      inherit (lib.types) bool;
      inherit (lib'.flake) mkFlavourOption;

      name = baseNameOf path;
    in
    {
      imports = [ path ];

      options.programs.${name} = {
        flavour = mkFlavourOption "${path}/flavours" "config1";

        disableModule = mkOption {
          description = "Whether to disable ${name} configuration";
          type = bool;
          default = false;
        };
      };
    };
in
{
  imports =
    map home-manager-program-import [
      ./alacritty
      ./bat
      ./ghostty
      ./yazi
      ./yt-dlp
      ./zathura
    ]
    ++ [
      ./aerc
      ./bash
      ./brave
      ./btop
      ./chromium
      ./delta
      ./diff-so-fancy
      ./direnv
      ./emacs
      ./eza
      ./fastfetch
      ./fd
      ./floorp
      ./fzf
      ./gemini-cli
      ./git
      ./htop
      ./hyprlock
      ./imv
      ./jellyfin
      ./khal
      ./kitty
      ./man
      ./mpv
      ./ncmpcpp
      ./neovide
      ./newsboat
      ./nh
      ./nixvim
      ./nix-your-shell
      ./nushell
      ./obs-studio
      ./oh-my-posh
      ./rofi
      ./ssh
      ./starship
      ./tealdeer
      ./thunar
      ./thunderbird
      ./tmux
      ./vim
      ./waybar
      ./wezterm
      ./wofi
      ./xournalpp
      ./zsh
    ];
}
