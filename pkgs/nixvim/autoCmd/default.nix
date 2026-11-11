{ ... }:
{
  autoCmd = [
    {
      desc = "Create missing parent directories before writing";
      group = "kickstart-create-parent-directories";
      event = [ "BufWritePre" ];
      pattern = [ "*" ];
      callback.__raw = ''
        function()
          if vim.bo.buftype ~= "" or vim.fn.expand("%") == "" then
            return
          end

          local dir = vim.fn.expand("%:p:h")
          if dir == "" or vim.fn.isdirectory(dir) == 1 then
            return
          end

          local choice = vim.fn.confirm(
            string.format('Directory "%s" does not exist. Create it?', dir),
            "&Yes\n&No",
            1
          )

          if choice == 1 then
            vim.fn.mkdir(dir, "p")
          else
            error("Write cancelled: parent directory does not exist")
          end
        end
      '';
    }
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
