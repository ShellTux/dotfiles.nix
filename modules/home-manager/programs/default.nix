{ ... }:
let
  home-manager-program-import =
    path:
    { config, lib', ... }:
    let
      inherit (lib'.flake) mkFlavourOption;

      name = baseNameOf path;
    in
    {
      imports = [ path ];

      options.programs.${name}.flavour = mkFlavourOption "${path}/flavours" "config1";
    };
in
{
  imports = map home-manager-program-import [ ./bat ] ++ [
    ./aerc
    ./alacritty
    ./bash
    ./bat
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
    ./ghostty
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
    ./yazi
    ./yt-dlp
    ./zathura
    ./zsh
  ];
}
