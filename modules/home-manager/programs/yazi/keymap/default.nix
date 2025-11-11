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
    keymap = {
      input.prepend_keymap = [
        {
          run = "close";
          on = [ "<c-q>" ];
        }
        {
          run = "close --submit";
          on = [ "<enter>" ];
        }
        {
          run = "escape";
          on = [ "<esc>" ];
        }
        {
          run = "backspace";
          on = [ "<backspace>" ];
        }
        {
          run = ''shell "$SHELL" --block --confirm'';
          on = [ "<A-s>" ];
          desc = "Open shell here";
        }
      ];
      mgr.prepend_keymap = [
        {
          run = "escape";
          on = [ "<esc>" ];
        }
        {
          run = "quit";
          on = [ "q" ];
        }
        {
          run = "close";
          on = [ "<c-q>" ];
        }
      ];
    };
  };
}
