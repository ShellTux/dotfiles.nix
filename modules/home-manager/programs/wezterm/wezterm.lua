local wezterm = require 'wezterm'

local action_callback = wezterm.action_callback
local action = wezterm.action
local mux = wezterm.mux

local utils = {
  RenameWorkspace = action.PromptInputLine({
    description = 'Workspace name:',
    action = action_callback(function(_, _, line)
      if line then
        mux.rename_workspace(
          mux.get_active_workspace(),
          line
        )
      end
    end)
  })
}

return {
  animation_fps = 60,
  check_for_updates = false,
  cursor_blink_ease_in = 'Linear',
  cursor_blink_ease_out = 'Linear',
  cursor_blink_rate = 800,
  default_cursor_style = 'BlinkingBlock',
  default_gui_startup_args = { 'connect', 'unix' },
  default_ssh_auth_sock = os.getenv 'SSH_AUTH_SOCK',
  enable_wayland = true,
  hide_tab_bar_if_only_one_tab = true,
  leader = { key = " ", mods = "CTRL", timeout_milliseconds = 1000 },
  max_fps = 120,
  mux_enable_ssh_agent = false,
  unix_domains = { { name = "unix" } },
  use_fancy_tab_bar = false,
  use_ime = true,
  warn_about_missing_glyphs = false,
  window_padding = { left = 2, right = 0, top = 2, bottom = 0, },

  font = wezterm.font_with_fallback {
    "JetBrains Mono",
    "Noto Color Emoji",
    "Symbols Nerd Font Mono",
  },

  colors = {
    cursor_bg = "#14BA0A",
    cursor_border = "#14BA0A",
  },

  keys = {
    -- Window management
    { key = "-",          mods = "LEADER",         action = action { SplitVertical = { domain = "CurrentPaneDomain" } } },
    { key = "\"",         mods = "LEADER | SHIFT", action = action { SplitVertical = { domain = "CurrentPaneDomain" } } },
    { key = "\\",         mods = "LEADER",         action = action.SplitHorizontal { domain = "CurrentPaneDomain" } },
    { key = "%",          mods = "LEADER | SHIFT", action = action.SplitHorizontal { domain = "CurrentPaneDomain" } },
    { key = "z",          mods = "LEADER",         action = "TogglePaneZoomState" },
    { key = "c",          mods = "LEADER",         action = action.SpawnCommandInNewTab { cwd = os.getenv('HOME') } },
    { key = "DownArrow",  mods = "SHIFT",          action = action.SpawnCommandInNewTab { cwd = os.getenv('HOME') } },

    { key = "h",          mods = "CTRL",           action = action.ActivatePaneDirection("Left") },
    { key = "j",          mods = "CTRL",           action = action.ActivatePaneDirection("Down") },
    { key = "k",          mods = "CTRL",           action = action.ActivatePaneDirection("Up") },
    { key = "l",          mods = "CTRL",           action = action.ActivatePaneDirection("Right") },
    { key = "h",          mods = "LEADER",         action = action.ActivatePaneDirection("Left") },
    { key = "j",          mods = "LEADER",         action = action.ActivatePaneDirection("Down") },
    { key = "k",          mods = "LEADER",         action = action.ActivatePaneDirection("Up") },
    { key = "l",          mods = "LEADER",         action = action.ActivatePaneDirection("Right") },
    { key = "DownArrow",  mods = "LEADER",         action = action.ActivatePaneDirection("Down") },
    { key = "LeftArrow",  mods = "LEADER",         action = action.ActivatePaneDirection("Left") },
    { key = "RightArrow", mods = "LEADER",         action = action.ActivatePaneDirection("Right") },
    { key = "UpArrow",    mods = "LEADER",         action = action.ActivatePaneDirection("Up") },
    { key = "PageUp",     mods = "CTRL",           action = action.DisableDefaultAssignment },
    { key = "PageDown",   mods = "CTRL",           action = action.DisableDefaultAssignment },
    { key = "PageUp",     mods = "CTRL | SHIFT",   action = action.DisableDefaultAssignment },
    { key = "PageDown",   mods = "CTRL | SHIFT",   action = action.DisableDefaultAssignment },
    { key = "LeftArrow",  mods = "CTRL",           action = action.MoveTabRelative(-1) },
    { key = "RightArrow", mods = "CTRL",           action = action.MoveTabRelative(1) },

    { key = "H",          mods = "LEADER",         action = action { AdjustPaneSize = { "Left", 5 } } },
    { key = "RightArrow", mods = "LEADER | SHIFT", action = action { AdjustPaneSize = { "Left", 5 } } },
    { key = "J",          mods = "LEADER",         action = action { AdjustPaneSize = { "Down", 5 } } },
    { key = "DownArrow",  mods = "LEADER | SHIFT", action = action { AdjustPaneSize = { "Down", 5 } } },
    { key = "K",          mods = "LEADER",         action = action { AdjustPaneSize = { "Up", 5 } } },
    { key = "UpArrow",    mods = "LEADER | SHIFT", action = action { AdjustPaneSize = { "Up", 5 } } },
    { key = "L",          mods = "LEADER",         action = action { AdjustPaneSize = { "Right", 5 } } },
    { key = "LeftArrow",  mods = "LEADER | SHIFT", action = action { AdjustPaneSize = { "Right", 5 } } },
    { key = "h",          mods = "LEADER | ALT",   action = action { AdjustPaneSize = { "Left", 1 } } },
    { key = "RightArrow", mods = "LEADER | ALT",   action = action { AdjustPaneSize = { "Left", 1 } } },
    { key = "j",          mods = "LEADER | ALT",   action = action { AdjustPaneSize = { "Down", 1 } } },
    { key = "DownArrow",  mods = "LEADER | ALT",   action = action { AdjustPaneSize = { "Down", 1 } } },
    { key = "k",          mods = "LEADER | ALT",   action = action { AdjustPaneSize = { "Up", 1 } } },
    { key = "UpArrow",    mods = "LEADER | ALT",   action = action { AdjustPaneSize = { "Up", 1 } } },
    { key = "l",          mods = "LEADER | ALT",   action = action { AdjustPaneSize = { "Right", 1 } } },
    { key = "LeftArrow",  mods = "LEADER | ALT",   action = action { AdjustPaneSize = { "Right", 1 } } },

    { key = 'LeftArrow',  mods = 'ALT',            action = action.SendKey { key = 'b', mods = 'ALT' } },
    { key = 'RightArrow', mods = 'ALT',            action = action.SendKey { key = 'f', mods = 'ALT' } },

    -- { key = "Tab",        mods = "LEADER",         action = action.ActivateLastTab },
    { key = "LeftArrow",  mods = "SHIFT",          action = action.ActivateTabRelative(-1) },
    { key = "RightArrow", mods = "SHIFT",          action = action.ActivateTabRelative(1) },
    { key = "1",          mods = "LEADER",         action = action { ActivateTab = 0 } },
    { key = "2",          mods = "LEADER",         action = action { ActivateTab = 1 } },
    { key = "3",          mods = "LEADER",         action = action { ActivateTab = 2 } },
    { key = "4",          mods = "LEADER",         action = action { ActivateTab = 3 } },
    { key = "5",          mods = "LEADER",         action = action { ActivateTab = 4 } },
    { key = "6",          mods = "LEADER",         action = action { ActivateTab = 5 } },
    { key = "7",          mods = "LEADER",         action = action { ActivateTab = 6 } },
    { key = "8",          mods = "LEADER",         action = action { ActivateTab = 7 } },
    { key = "9",          mods = "LEADER",         action = action { ActivateTab = 8 } },
    { key = "x",          mods = "LEADER",         action = action { CloseCurrentPane = { confirm = true } } },

    { key = "s",          mods = "LEADER",         action = action.ShowLauncherArgs { flags = 'FUZZY|WORKSPACES' } },
    { key = ",",          mods = "LEADER",         action = utils.RenameWorkspace },

    -- Open wezterm config file
    -- {
    --   key = ".",
    --   mods = "LEADER",
    --   action = action.SpawnCommandInNewTab {
    --     cwd = os.getenv('WEZTERM_CONFIG_DIR'),
    --     set_environment_variables = {
    --       TERM = 'screen-256color',
    --     },
    --     args = { os.getenv('EDITOR'), os.getenv('WEZTERM_CONFIG_FILE') },
    --   },
    -- },

    -- Activate Copy Mode
    { key = "[",          mods = "LEADER",         action = action.ActivateCopyMode },
    -- Paste from Copy Mode
    { key = "]",          mods = "LEADER",         action = action.PasteFrom("PrimarySelection") },
  },

  key_tables = {
    -- added new shortcuts to the end
    copy_mode = {
      { key = "c",          mods = "CTRL",  action = action.CopyMode("Close") },
      { key = "g",          mods = "CTRL",  action = action.CopyMode("Close") },
      { key = "q",          mods = "NONE",  action = action.CopyMode("Close") },
      { key = "Escape",     mods = "NONE",  action = action.CopyMode("Close") },

      { key = "h",          mods = "NONE",  action = action.CopyMode("MoveLeft") },
      { key = "j",          mods = "NONE",  action = action.CopyMode("MoveDown") },
      { key = "k",          mods = "NONE",  action = action.CopyMode("MoveUp") },
      { key = "l",          mods = "NONE",  action = action.CopyMode("MoveRight") },

      { key = "LeftArrow",  mods = "NONE",  action = action.CopyMode("MoveLeft") },
      { key = "DownArrow",  mods = "NONE",  action = action.CopyMode("MoveDown") },
      { key = "UpArrow",    mods = "NONE",  action = action.CopyMode("MoveUp") },
      { key = "RightArrow", mods = "NONE",  action = action.CopyMode("MoveRight") },

      { key = "RightArrow", mods = "ALT",   action = action.CopyMode("MoveForwardWord") },
      { key = "f",          mods = "ALT",   action = action.CopyMode("MoveForwardWord") },
      { key = "Tab",        mods = "NONE",  action = action.CopyMode("MoveForwardWord") },
      { key = "w",          mods = "NONE",  action = action.CopyMode("MoveForwardWord") },
      { key = "e",          mods = "NONE",  action = action.CopyMode("MoveForwardWordEnd") },

      { key = "LeftArrow",  mods = "ALT",   action = action.CopyMode("MoveBackwardWord") },
      { key = "b",          mods = "ALT",   action = action.CopyMode("MoveBackwardWord") },
      { key = "Tab",        mods = "SHIFT", action = action.CopyMode("MoveBackwardWord") },
      { key = "b",          mods = "NONE",  action = action.CopyMode("MoveBackwardWord") },

      { key = "0",          mods = "NONE",  action = action.CopyMode("MoveToStartOfLine") },
      { key = "Enter",      mods = "NONE",  action = action.CopyMode("MoveToStartOfNextLine") },

      { key = "$",          mods = "NONE",  action = action.CopyMode("MoveToEndOfLineContent") },
      { key = "$",          mods = "SHIFT", action = action.CopyMode("MoveToEndOfLineContent") },
      { key = "^",          mods = "NONE",  action = action.CopyMode("MoveToStartOfLineContent") },
      { key = "^",          mods = "SHIFT", action = action.CopyMode("MoveToStartOfLineContent") },
      { key = "m",          mods = "ALT",   action = action.CopyMode("MoveToStartOfLineContent") },

      { key = " ",          mods = "NONE",  action = action.CopyMode { SetSelectionMode = "Cell" } },
      { key = "v",          mods = "NONE",  action = action.CopyMode { SetSelectionMode = "Cell" } },
      { key = "V",          mods = "NONE",  action = action.CopyMode { SetSelectionMode = "Line" } },
      { key = "V",          mods = "SHIFT", action = action.CopyMode { SetSelectionMode = "Line" } },
      { key = "v",          mods = "CTRL",  action = action.CopyMode { SetSelectionMode = "Block" } },

      { key = "G",          mods = "NONE",  action = action.CopyMode("MoveToScrollbackBottom") },
      { key = "G",          mods = "SHIFT", action = action.CopyMode("MoveToScrollbackBottom") },
      { key = "g",          mods = "NONE",  action = action.CopyMode("MoveToScrollbackTop") },

      { key = "H",          mods = "NONE",  action = action.CopyMode("MoveToViewportTop") },
      { key = "H",          mods = "SHIFT", action = action.CopyMode("MoveToViewportTop") },
      { key = "M",          mods = "NONE",  action = action.CopyMode("MoveToViewportMiddle") },
      { key = "M",          mods = "SHIFT", action = action.CopyMode("MoveToViewportMiddle") },
      { key = "L",          mods = "NONE",  action = action.CopyMode("MoveToViewportBottom") },
      { key = "L",          mods = "SHIFT", action = action.CopyMode("MoveToViewportBottom") },

      { key = "o",          mods = "NONE",  action = action.CopyMode("MoveToSelectionOtherEnd") },
      { key = "O",          mods = "NONE",  action = action.CopyMode("MoveToSelectionOtherEndHoriz") },
      { key = "O",          mods = "SHIFT", action = action.CopyMode("MoveToSelectionOtherEndHoriz") },

      { key = "PageUp",     mods = "NONE",  action = action.CopyMode("PageUp") },
      { key = "PageDown",   mods = "NONE",  action = action.CopyMode("PageDown") },
      { key = "u",          mods = "CTRL",  action = action.CopyMode("PageUp") },
      { key = "d",          mods = "CTRL",  action = action.CopyMode("PageDown") },

      { key = "b",          mods = "CTRL",  action = action.CopyMode("PageUp") },
      { key = "f",          mods = "CTRL",  action = action.CopyMode("PageDown") },

      -- Enter y to copy and quit the copy mode.
      {
        key = "y",
        mods = "NONE",
        action = action.Multiple {
          action.CopyTo("ClipboardAndPrimarySelection"),
          action.CopyMode("Close"),
        }
      },
      -- Enter search mode to edit the pattern.
      -- When the search pattern is an empty string the existing pattern is preserved
      { key = "/", mods = "NONE", action = action { Search = { CaseSensitiveString = "" } } },
      { key = "?", mods = "NONE", action = action { Search = { CaseInSensitiveString = "" } } },
      { key = "n", mods = "CTRL", action = action { CopyMode = "NextMatch" } },
      { key = "p", mods = "CTRL", action = action { CopyMode = "PriorMatch" } },
    },

    search_mode = {
      { key = "Escape", mods = "NONE", action = action { CopyMode = "Close" } },
      -- Go back to copy mode when pressing enter, so that we can use unmodified keys like "n"
      -- to navigate search results without conflicting with typing into the search area.
      { key = "Enter",  mods = "NONE", action = "ActivateCopyMode" },
      { key = "c",      mods = "CTRL", action = "ActivateCopyMode" },
      { key = "n",      mods = "CTRL", action = action { CopyMode = "NextMatch" } },
      { key = "p",      mods = "CTRL", action = action { CopyMode = "PriorMatch" } },
      { key = "r",      mods = "CTRL", action = action.CopyMode("CycleMatchType") },
      { key = "u",      mods = "CTRL", action = action.CopyMode("ClearPattern") },
    },
  },
}
