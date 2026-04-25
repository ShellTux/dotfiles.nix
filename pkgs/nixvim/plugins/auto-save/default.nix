{ ... }:
{
  plugins.auto-save.settings.debounce_delay = 5 * 1000;

  keymaps = [
    {
      action = "<CMD>ASToggle<CR>";
      key = "<leader>st";
      options = {
        silent = true;
        desc = "Toggle auto-save";
      };
    }
  ];
}
