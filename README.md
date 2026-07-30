# dotfiles

Personal terminal environment for macOS: WezTerm + tmux + Neovim + zsh, themed
with rose-pine-moon and a MesloLGS Nerd Font.

## Layout

```
dotfiles/
  wezterm/wezterm.lua     -> ~/.wezterm.lua
  tmux/tmux.conf          -> ~/.tmux.conf
  nvim/init.lua           -> ~/.config/nvim/init.lua
  zsh/zshrc               -> ~/.zshrc
  zsh/zshenv              -> ~/.zshenv
  zsh/zprofile            -> ~/.zprofile
  zsh/*.zsh               -> ~/.config/zsh/*.zsh   (history, aliases, fzf, plugins, prompt)
  starship/starship.toml  -> ~/.config/starship.toml
  cheatsheets/*.md        -> ~/.*-cheatsheet.md
  AGENTS.md               -> ~/.claude/CLAUDE.md, ~/.codex/AGENTS.md, ~/AGENTS.md, ~/CLAUDE.md
```

`AGENTS.md` is one global instruction file linked to every location Claude and
Codex read, so both agents follow the same rules on any machine.

## Install

```sh
git clone <this-repo> ~/dotfiles
~/dotfiles/install.sh          # symlinks everything (backs up existing files to *.bak)
```

### Dependencies (macOS)

```sh
brew install --cask wezterm font-meslo-lg-nerd-font
brew install tmux neovim starship zoxide eza bat fd fzf ripgrep git-delta lazygit

# tmux plugin manager
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
# then in tmux: prefix + I  (or it auto-installs on first launch)
```

zsh plugins and nvim plugins install themselves on first launch.

## Agent skills

Skill content is not vendored here. `skills-install.sh` installs skills via their
own tooling and symlinks them into the agent dirs (`~/.claude/skills`,
`~/.codex/skills`) so they track upstream instead of drifting:

```sh
~/dotfiles/skills-install.sh
```

Installs the agent toolchain: `treehouse` (pooled worktrees), `gnhf` (overnight
orchestrator + its skill), `tasks-axi` (backlog CLI), and clones the `firstmate`
agent distro to `~/firstmate` (clone only - never auto-launched).

## Machine-local / secret config

Anything machine-specific or secret (work credentials, per-host env) goes in
`~/.zshrc.local`, which `.zshrc` sources if present. It is gitignored on purpose
so nothing sensitive lands in the repo.

## Keys

Each tool has a cheat sheet. In the shell run `cheat` to fuzzy-search all of
them, or `cheat {nvim|tmux|zsh|wezterm}` to open one. In nvim: `Space ?`.
In tmux: `prefix ?`.

- tmux prefix: `Ctrl-Space`
- wezterm leader: `Ctrl-b`
- nvim leader: `Space`
