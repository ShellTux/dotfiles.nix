{ config, lib, ... }:
let
  inherit (lib) mkIf;
  cfg = config.wayland.windowManager.hyprland;
in
{
  config.wayland.windowManager.hyprland.settings = mkIf (cfg.enable && !cfg.disableModule) {
    on._args = [
      "window.open"
      {
        _type = "lua-inline";
        expr = ''
          function(w)
              if w.class ~= "firefox" then return end
              if w.initial_title ~= "Mozilla Firefox" then return end

              local ff_windows = hl.get_windows({ class = "firefox" })
              if #ff_windows <= 1 then return end

              hl.dispatch(hl.dsp.window.float({ action = "set", window = w }))

              local sub
              sub = hl.on("window.title", function(tw)
                  if tw.address ~= w.address then return end
                  if tw.title == ""
                      or tw.title == "Mozilla Firefox"
                      or tw.title == "about:blank"
                      or tw.title:match("^about:.*Mozilla Firefox$") then return end

                  sub:remove()

                  if tw.title:match("^Extension:") then
                      hl.dispatch(hl.dsp.window.resize({ x = 800, y = 600, window = tw }))
                      hl.dispatch(hl.dsp.window.center({ window = tw }))
                      hl.dispatch(hl.dsp.focus({ window = tw }))
                  else
                      hl.dispatch(hl.dsp.window.float({ action = "unset", window = tw }))
                  end
              end)
          end
        '';
      }
    ];
  };
}
