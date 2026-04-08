{ ... }:
let
  wrap = path: _: { imports = [ path ]; };
in
{
  flake.wrappers = {
    btop = wrap ./btop;
    eza = wrap ./eza;
    fastfetch = wrap ./fastfetch;
    fd = wrap ./fd;
    git = wrap ./git;
    htop = wrap ./htop;
    imv = wrap ./imv;
    kitty = wrap ./kitty;
    mpv = wrap ./mpv;
    noctalia-shell = wrap ./noctalia-shell;
    vim = wrap ./vim;
    waybar = wrap ./waybar;
    yazi = wrap ./yazi;
    yt-dlp = wrap ./yt-dlp;
    zathura = wrap ./zathura;
  };
}
