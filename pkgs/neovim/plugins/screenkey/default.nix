{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf mkMerge;
  inherit (pkgs) callPackage;

  screenkey = callPackage ./screenkey.nix { };

  cfg = config.programs.nixvim.plugins.screenkey;
in
{
  options.programs.nixvim.plugins.screenkey = {
    enable = mkEnableOption "Wether to enable screenkey.nvim";
  };

  config.programs.nixvim = {
    extraConfigLua = mkIf cfg.enable (mkMerge [
      "vim.cmd[[set winbar=%{%v:lua.require('screenkey').get_keys()%}]]"
      "require('screenkey').setup({ win_opts = { width=70 }})"
    ]);

    extraPlugins = mkIf cfg.enable [ screenkey ];
    globals.screenkey_statusline_component = mkIf cfg.enable true;
    keymaps =
      let
        cmd = command: "<CMD>${command}<CR>";
      in
      mkIf cfg.enable [
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
  };
}
