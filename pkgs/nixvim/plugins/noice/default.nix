{ ... }:
{
  keymaps = [
    {
      key = "<leader>nd";
      action = "<cmd>NoiceDismiss<cr>";
      options.desc = "Dismiss Noice Notifications";
    }
  ];

  plugins.noice.settings.views = {
    cmdline_popup = {
      position = {
        row = 5;
        col = "50%";
      };
      size = {
        width = 60;
        height = "auto";
      };
    };
    popupmenu = {
      relative = "editor";
      position = {
        row = 8;
        col = "50%";
      };
      size = {
        width = 60;
        height = 10;
      };
      border = {
        style = "rounded";
        padding = [
          0
          1
        ];
      };
      win_options.winhighlight = {
        Normal = "Normal";
        FloatBorder = "DiagnosticInfo";
      };
    };
  };
}
