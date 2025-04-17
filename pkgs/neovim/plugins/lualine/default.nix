{
  plugins.lualine = {
    settings.sections = {
      lualine_a = [
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
        "mode"
      ];
      lualine_x = [
        { __raw = "function() return ' ' .. vim.g.colors_name end"; }
        "encoding"
        "fileformat"
        "filetype"
      ];
    };
  };
}
