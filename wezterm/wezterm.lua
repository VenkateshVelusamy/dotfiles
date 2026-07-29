local wezterm = require("wezterm")
local config = wezterm.config_builder()

-- Font: MesloLGS Nerd Font (installed via brew). Nerd Font glyphs make the
-- tmux/nvim/starship icons render instead of showing as boxes.
config.font = wezterm.font("MesloLGS Nerd Font")
config.font_size = 12.0   -- matches Terminal.app (SF Mono 12)
config.line_height = 1.05

-- rose-pine-moon: the shared theme across wezterm + nvim + shell. This sets the
-- ANSI palette, so zsh output, starship, and bat (theme "ansi") all follow it.
config.color_scheme = "rose-pine-moon"

-- Heavy frosted-glass look (kunchenguid). Lower opacity = more see-through.
config.window_background_opacity = 0.6
config.macos_window_background_blur = 30

-- Show the tab bar only when there are 2+ tabs, so a single-pane session stays
-- clean but WezTerm's native tabs are visible when you open them.
config.hide_tab_bar_if_only_one_tab = true
config.use_fancy_tab_bar = true
config.window_decorations = "TITLE | RESIZE"   -- native title bar: traffic lights, fullscreen button, drag-to-move
config.window_padding = { left = 8, right = 8, top = 8, bottom = 8 }

config.scrollback_lines = 10000
config.audible_bell = "Disabled"

-- ── Keybindings: mirror tmux's "prefix then key" grammar ──────────────────
-- Leader = Ctrl-b (tmux's OLD prefix, now free; distinct from tmux's Ctrl-Space
-- so the two layers never fight). Bare Ctrl-h/j/k/l are left UNBOUND on purpose
-- so nvim<->tmux seamless navigation still owns them.
local act = wezterm.action
config.leader = { key = "b", mods = "CTRL", timeout_milliseconds = 1000 }

config.keys = {
  -- Tabs (tmux windows)
  { key = "c", mods = "LEADER", action = act.SpawnTab("CurrentPaneDomain") },
  { key = "n", mods = "LEADER", action = act.ActivateTabRelative(1) },
  { key = "p", mods = "LEADER", action = act.ActivateTabRelative(-1) },
  { key = "x", mods = "LEADER", action = act.CloseCurrentPane({ confirm = true }) },
  { key = "&", mods = "LEADER|SHIFT", action = act.CloseCurrentTab({ confirm = true }) },

  -- Splits: two-step like tmux `prefix s` then v/h. `s` enters a key table.
  { key = "s", mods = "LEADER", action = act.ActivateKeyTable({ name = "split", one_shot = true, timeout_milliseconds = 1000 }) },

  -- Pane focus (matches tmux `prefix h/j/k/l`)
  { key = "h", mods = "LEADER", action = act.ActivatePaneDirection("Left") },
  { key = "j", mods = "LEADER", action = act.ActivatePaneDirection("Down") },
  { key = "k", mods = "LEADER", action = act.ActivatePaneDirection("Up") },
  { key = "l", mods = "LEADER", action = act.ActivatePaneDirection("Right") },

  -- Zoom (tmux `prefix m` / `prefix z`)
  { key = "z", mods = "LEADER", action = act.TogglePaneZoomState },
  { key = "m", mods = "LEADER", action = act.TogglePaneZoomState },

  -- Reload (tmux `prefix r`)
  { key = "r", mods = "LEADER", action = act.ReloadConfiguration },

  -- Copy mode (tmux `prefix [`)
  { key = "[", mods = "LEADER", action = act.ActivateCopyMode },

  -- Send a literal Ctrl-b to the program inside (press leader twice)
  { key = "b", mods = "LEADER|CTRL", action = act.SendKey({ key = "b", mods = "CTRL" }) },

  -- Jump to tab by number (tmux `prefix 1..9`)
  { key = "1", mods = "LEADER", action = act.ActivateTab(0) },
  { key = "2", mods = "LEADER", action = act.ActivateTab(1) },
  { key = "3", mods = "LEADER", action = act.ActivateTab(2) },
  { key = "4", mods = "LEADER", action = act.ActivateTab(3) },
  { key = "5", mods = "LEADER", action = act.ActivateTab(4) },
  { key = "6", mods = "LEADER", action = act.ActivateTab(5) },
  { key = "7", mods = "LEADER", action = act.ActivateTab(6) },
  { key = "8", mods = "LEADER", action = act.ActivateTab(7) },
  { key = "9", mods = "LEADER", action = act.ActivateTab(8) },
}

config.key_tables = {
  -- After `LEADER s`: v = vertical (side by side), h = horizontal (stacked).
  -- Matches your tmux `prefix s v` / `prefix s h` exactly.
  split = {
    { key = "v", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
    { key = "h", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
  },
}

-- Send Option as a real Alt/Meta so Alt-based keys (fzf Alt-f, tmux, nvim
-- Alt-j/k line-move) work rather than typing accented characters.
config.send_composed_key_when_left_alt_is_pressed = false
config.send_composed_key_when_right_alt_is_pressed = false

return config
