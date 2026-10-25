{ ... }:
{
  autoCmd = [
    {
      desc = "Highlight when yanking (copying) text";
      group = "kickstart-highlight-yank";
      event = [ "TextYankPost" ];
      callback.__raw = ''
        function()
          if vim.fn.has("nvim-0.13") == 1 then
            vim.hl.hl_op()
          else
            (vim.hl or vim.highlight).on_yank()
          end
        end
      '';
    }
    {
      command = "setlocal fileencodings=cp437,utf-8";
      event = [ "BufReadPre" ];
      pattern = [ "*.nfo" ];
    }
  ];
}
