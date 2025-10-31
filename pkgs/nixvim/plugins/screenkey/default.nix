{ pkgs, ... }:
let
  inherit (builtins) concatStringsSep;
  inherit (pkgs) callPackage;

  screenkey = callPackage ./screenkey.nix { };
in
{
  extraConfigLua = concatStringsSep "\n" [
    "vim.cmd[[set winbar=%{%v:lua.require('screenkey').get_keys()%}]]"
    "require('screenkey').setup({ win_opts = { width=70 }})"
  ];

  extraPlugins = [ screenkey ];
  globals.screenkey_statusline_component = true;
  keymaps =
    let
      cmd = command: "<CMD>${command}<CR>";
    in
    [
      {
        action = cmd "Screenkey toggle";
        key = "<leader>skt";
        options = {
          silent = true;
          desc = "Toggle Screenkey";
        };
      }
      {
        action.__raw = ''
          function()
          	vim.cmd([[Screenkey toggle_statusline_component]])
          	if vim.g.screenkey_statusline_component then
          		vim.cmd([[set winbar=%{%v:lua.require(\'screenkey\').get_keys()%}]])
          	else
          		vim.cmd([[set winbar=]])
          	end
          end
        '';
        key = "<leader>skst";
        options = {
          silent = true;
          desc = "Toggle Screenkey status line";
        };
      }
    ];
}
