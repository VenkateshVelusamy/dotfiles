# zsh cheat sheet

Config: ~/.zshrc sources ~/.config/zsh/*.zsh  (history, aliases, fzf, plugins, prompt)
Prompt theme: ~/.config/starship.toml

## Vi mode (zsh-vi-mode)
    Esc          leave insert -> normal mode (cursor becomes a block)
    i a o        enter insert (as in vim)
    k / j        (normal mode) scroll history up/down by prefix
    v            (normal mode) edit the command line in $EDITOR (nvim)
    dd cc ciw    normal-mode edits work on the command line

## fzf
    Ctrl-R       fuzzy search command history
    Ctrl-T       fuzzy-pick a file, insert its path (bat preview)
    Alt-C        fuzzy-pick a subdir and cd into it

## History
    Up / Down    filter history by the prefix already typed
    (shared across all open shells; leading space keeps a cmd out of history)

## Navigation
    z <name>     zoxide smart cd (jumps to a dir you've visited: z substrate)
    zi           zoxide interactive pick
    <dirname>    autocd — just type a dir name to cd into it
    -            cd to previous directory

## Modern CLI (aliased)
    ls / ll / la eza with icons + git status (la includes hidden)
    tree         eza tree view
    cat          bat (syntax highlight + line numbers)
    grep         ripgrep (rg)
    vim          nvim

## Git helpers
    glog         git log (pager quits if it fits one screen)
    gadog        git log --all --decorate --oneline --graph

## Autosuggestions (greyed-out, from history)
    ->  / End    accept the full suggestion
    (fast-syntax-highlighting colors commands live; red = not found)

## Maintenance
    zplugin-update   update all zsh plugins (~/.config/zsh/plugins/*)
    exec zsh         reload the shell after editing config
