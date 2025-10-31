{ noice, ... }:
let
  lualine_a =
    (
      if noice.enable then
        [
          {
            __unkeyed-1.__raw = ''
              function()
                return require('noice').api.statusline.mode.get():gsub('recording', '󰑊')
              end
            '';
            cond.__raw = ''
              function()
                local noice = require("noice")
                if noice.api.statusline.mode.has() and noice.api.statusline.mode.get():find("^recording") then
                  return true
                else
                  return false
                end
              end
            '';
            color.fg = "#ff0000";
          }
        ]
      else
        [
          {
            __raw = "function() local recording_register = vim.fn.reg_recording(); return (recording_register ~= '') and ('%#MacroRecording#󰑊 @' .. recording_register) or '' end";
          }
        ]
    )
    ++ [ "mode" ];
in
{
  extraConfigLua = "vim.cmd [[ highlight MacroRecording guifg=#FF0000 ]]";

  plugins.lualine.settings.sections = {
    inherit lualine_a;

    lualine_x = [
      { __raw = "function() return ' ' .. vim.g.colors_name end"; }
      "encoding"
      "fileformat"
      "filetype"
    ];
  };
}
