{
  ...
}:
let
  cmd = action: "<CMD>${action}<CR>";
in
{
  keymaps = [
    {
      action = cmd "vertical resize -2";
      key = "<Left>";
      options.silent = true;
    }
    {
      action = cmd "vertical resize +2";
      key = "<Right>";
      options.silent = true;
    }
    {
      action = cmd "resize -2";
      key = "<up>";
      options.silent = true;
    }
    {
      action = cmd "resize +2";
      key = "<down>";
      options.silent = true;
    }
    {
      action = cmd "tabmove -1";
      key = "<C-S-PageUp>";
    }
    {
      action = "tabmove +1";
      key = "<C-S-PageDown>";
    }
    {
      action = cmd "nohlsearch";
      key = "<leader>h";
    }
    {
      action = "<gv";
      key = "<";
      mode = "v";
    }
    {
      action = ">gv";
      key = ">";
      mode = "v";
    }
    {
      action = "<Esc>";
      key = "jj";
      mode = "i";
    }
    {
      action = cmd "cnext";
      key = "]q";
      mode = "n";
      options.desc = "Next quickfix";
    }
    {
      action = cmd "cprev";
      key = "[q";
      mode = "n";
      options.desc = "Previous quickfix";
    }
  ];
}
