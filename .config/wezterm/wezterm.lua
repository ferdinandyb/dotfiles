-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This table will hold the configuration.
local config = {}

-- In newer versions of wezterm, use the config_builder which will
-- help provide clearer error messages
if wezterm.config_builder then
  config = wezterm.config_builder()
end

-- This is where you actually apply your config choices

-- For example, changing the color scheme:
config.color_scheme = 'Dracula'
if wezterm.target_triple == 'x86_64-pc-windows-msvc' then
  config.default_prog = { 'wsl', '--cd', '~' }
end
config.window_close_confirmation = 'NeverPrompt'
-- config.disable_default_key_bindings = true
config.keys = {
  -- Turn off the default CMD-m Hide action, allowing CMD-m to
  -- be potentially recognized and handled by the tab
  {
    key = 'V',
    mods = 'CTRL',
    action = wezterm.action.PasteFrom 'Clipboard'
  },
  {
    key = 'C',
    mods = 'CTRL',
    action = wezterm.action.CopyTo 'Clipboard'
  },
  {
    key = '0',
    mods = 'CTRL|SHIFT',
    action = wezterm.action.ActivateTab(0)
  },
  {
    key = '1',
    mods = 'CTRL|SHIFT',
    action = wezterm.action.ActivateTab(1)
  }
}
config.check_for_updates = false
config.hide_tab_bar_if_only_one_tab = true
config.scrollback_lines = 35000
config.font_size = 13
config.unicode_version = 15

config.font = wezterm.font('CaskaydiaCove Nerd Font', { weight = 'Light' })
return config
