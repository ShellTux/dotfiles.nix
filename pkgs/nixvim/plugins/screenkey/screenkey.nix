{ vimUtils, fetchFromGitHub, ... }:
let
  inherit (vimUtils) buildVimPlugin;
in
buildVimPlugin {
  name = "screenkey.nvim";
  src = fetchFromGitHub {
    owner = "NStefan002";
    repo = "screenkey.nvim";
    rev = "v2.4.1";
    hash = "sha256-RTUkG77gM6b1PKv5AqB0/U4satHwQ+q5kJYM3U/mkAw=";
  };
}
