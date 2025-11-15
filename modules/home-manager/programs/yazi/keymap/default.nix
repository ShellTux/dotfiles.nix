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
  programs.yazi = mkIf (cfg.enable && !cfg.disableModule) {
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
        {
          run = ''shell "$SHELL" --block'';
          on = [ "!" ];
          desc = "Open shell here";
        }
      ];
    };
  };
}
