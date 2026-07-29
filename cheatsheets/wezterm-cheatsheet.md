# WezTerm cheat sheet

Config: ~/.wezterm.lua  (auto-reloads on save, or LEADER r)
LEADER = Ctrl-b  (distinct from tmux's Ctrl-Space so the layers don't fight).
Grammar mirrors tmux: press LEADER, release, then a key.

## Why a different leader than tmux?
Keys flow WezTerm -> tmux -> nvim (outer to inner). WezTerm eats its keys first,
so it must NOT use Ctrl-Space (tmux's prefix) or bare Ctrl-h/j/k/l (nvim<->tmux
nav) -- those are left free to pass through. Ctrl-b is tmux's OLD prefix, now unused.

## Tabs (WezTerm's own; ephemeral -- prefer tmux windows for real work)
    LEADER c        new tab
    LEADER n / p    next / previous tab
    LEADER 1..9     jump to tab N
    LEADER Shift-&  close tab (confirm)

## Panes (splits within a tab)
    LEADER s v      split vertical (side by side)   -- like tmux prefix s v
    LEADER s h      split horizontal (stacked)      -- like tmux prefix s h
    LEADER h/j/k/l  move focus between panes
    LEADER z (or m) zoom pane fullscreen (toggle)
    LEADER x        close pane (confirm)

## Other
    LEADER [        copy mode (vim-like selection)
    LEADER r        reload config
    LEADER Ctrl-b   send a literal Ctrl-b to the program inside
    Cmd-c / Cmd-v   copy / paste (native macOS)
    Cmd-f           search scrollback
    Cmd +/-/0       font size up / down / reset
    Cmd-Shift-p     command palette (discover everything)

## tmux vs WezTerm (which to use)
    Use tmux windows/panes for real work -- they PERSIST (detach, reboot-restore).
    WezTerm tabs vanish on close. Handy for quick non-tmux shells only.
