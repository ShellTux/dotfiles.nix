{ ... }:
{
  autoCmd = [
    {
      desc = "Highlight when yanking (copying) text";
      group = "kickstart-highlight-yank";
      event = [ "TextYankPost" ];
      callback.__raw = "function() vim.highlight.on_yank() end";
    }
    {
      command = "setlocal fileencodings=cp437,utf-8";
      event = [ "BufReadPre" ];
      pattern = [ "*.nfo" ];
    }
  ];
}
