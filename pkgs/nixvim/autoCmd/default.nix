{ ... }:
{
  autoCmd = [
    {
      desc = "Highlight when yanking (copying) text";
      group = "kickstart-highlight-yank";
      event = [ "TextYankPost" ];
      callback.__raw = "function() vim.highlight.on_yank() end";
    }
  ];
}
