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
    vim = wrap ./vim;
    noctalia-shell = wrap ./noctalia-shell;
  };
}
