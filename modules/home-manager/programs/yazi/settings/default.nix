{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkIf;

  cfg = config.programs.yazi;
in
{
  programs.yazi = mkIf cfg.enable {
    settings = {
      opener.extract = [
        {
          run = ''unar "$1"'';
          desc = "Extract here";
          for = "unix";
        }
      ];
    };
  };
}
