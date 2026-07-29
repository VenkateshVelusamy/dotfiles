# tmux cheat sheet

PREFIX = Ctrl-Space  (written PFX below). Press PFX, release, then the key.
Reload after editing ~/.tmux.conf:  PFX r

## Mental model
    session   = whole workspace (survives closing the terminal)
      window  = a "tab" (one full screen)
        pane  = a split inside a window

## Sessions
    tmux new -s NAME       start a named session
    PFX d                  detach (keeps running in background)
    tmux ls                list running sessions
    tmux attach -t NAME    reattach
    PFX $                  rename current session
    tmux kill-session -t NAME   kill it

## Windows (tabs)
    PFX c        new window (opens in current dir)
    PFX n / p    next / previous window
    PFX 1..9     jump to window N  (numbered from 1)
    PFX ,        rename current window
    PFX w        pick from a list
    PFX &        close current window

## Panes (splits)
    PFX s v      vertical split (side by side)   ~ nvim <leader>sv
    PFX s h      horizontal split (stacked)      ~ nvim <leader>sh
    Ctrl-h/j/k/l MOVE focus between panes (NO prefix; crosses into nvim splits)
    PFX h/j/k/l  resize (repeatable: keep tapping after PFX)
    PFX m        zoom pane to fullscreen (toggle)
    PFX o        cycle to next pane
    PFX !        convert pane into its own window
  Rearrange panes:
    PFX { / PFX }   swap pane with previous / next
                    (split then PFX { to put the new pane on the LEFT)
    PFX Ctrl-o      rotate all panes through the layout
    PFX Space       cycle preset layouts (even, main-vertical, ...)
  Close:
    PFX x        close current pane (asks to confirm)

## Copy mode (vim motions)
    PFX [        enter copy mode
    h j k l      move; w b words; / search; gg / G top/bottom
    v            begin selection
    y            yank -> system clipboard (paste with Cmd-V)
    q / Esc      exit copy mode
    (mouse: scroll to enter; drag to select)

## Popups / plugins
    PFX g        lazygit (floating, scoped to current dir)
    PFX Ctrl-s   save session layout   (tmux-resurrect)
    PFX Ctrl-r   restore session layout
    PFX I        install plugins listed in config
    PFX U        update plugins

## What runs automatically
    tmux-continuum   auto-saves every 5 min; auto-restores on tmux start
    tmux-resurrect   captures pane contents too (@resurrect-capture-pane-contents)
    tmux-yank        copy in copy mode -> system clipboard

## Statusline (top bar)
    left    yellow pill = current session name
    middle  windows as index:name; current one is brighter
    right   clock HH:MM | date YYYY-MM-DD | user@host
    (icons need a Nerd Font; boxes = font not set)
