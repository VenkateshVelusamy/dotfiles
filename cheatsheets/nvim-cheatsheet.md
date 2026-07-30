# nvim cheat sheet

LEADER = Space  (written SPC below). Open this sheet:  SPC ?
Config: ~/.config/nvim/init.lua

## Movement & editing
    s              JUMP: type a match, then a label, to leap on screen [nvim-jump]
                   (works with operators: ds<label> deletes to the target)
    7j / 7k        down / up 7 lines (any count; relnumber shows the count)
    :N  or NG  Ngg go to absolute line N   (:7, 7G, 7gg -> line 7)
    gg / G         first line / last line
    0 / ^ / $      start of line / first non-blank / end of line
    w / b / e      forward word / back word / end of word
    { / }          previous / next paragraph (blank-line block)
    % / f{c}/t{c}  matching bracket / jump to (or before) char c on line
    Ctrl-o/Ctrl-i  jump back / forward in the jump history
    j / k          move down/up (wrap-aware: moves by screen line)
    n / N          next/prev search result (auto-centered)
    Ctrl-d/Ctrl-u  half-page down/up (auto-centered)
    J              join line below, keep cursor put
    < / >          (visual) indent left/right and keep selection
    Alt-h/j/k/l    move line (normal) or selection (visual)   [mini.move]
    SPC c          clear search highlight
    SPC x          delete without yanking (black-hole)
    SPC p          (visual) paste over without losing yank
    SPC pa         copy full file path to clipboard

## GitHub/GHE PR review (octo.nvim)
  LLDR = localleader = Space (same as SPC). Run from inside the repo clone.
  For a clone whose origin is a local path (not a github/ghe URL), octo can't
  resolve the server repo -> add a real remote once:
    git remote add ghe https://siemens.ghe.com/<owner>/<repo>.git && git fetch ghe
  (config already prefers a "ghe" remote, then origin; normal clones need nothing)
  Open / list:
    SPC op         list open PRs (picker)         :Octo pr list
    SPC or         start / resume a review        :Octo review
    :Octo pr edit N     open PR #N as a buffer
    :Octo pr search TXT search PRs
    :Octo issue list / :Octo issue edit N   issues
  In the PR buffer:
    Enter          show PR options menu
    LLDR vs / vr   start / resume a review
    LLDR po        checkout the PR branch locally
    LLDR pc/pf/pd  list commits / changed files / diff
    LLDR pm        merge   (psm squash-merge, prm rebase-merge)   [careful]
    LLDR ic / io   close / reopen PR
    LLDR va / vd   add / remove reviewer
    LLDR ca/cr/cd  add comment / reply / delete comment
    SPC qa         approve PR    Ctrl-r reload   Ctrl-b browser   Ctrl-y copy URL
  In the review diff (walk the changes):
    ]q / [q        next / previous changed FILE
    ]Q / [Q        first / last changed file
    ]u / [u        next / previous UNVIEWED file
    ]c / [c        next / previous changed section (hunk) within a file
    ]t / [t        next / previous comment THREAD
    LLDR SPC       toggle this file's "viewed" state
    LLDR e / b     focus / hide the changed-file panel
    gf             jump to the real file
    zo / zR        open one fold (the "+N lines" collapsed context) / open all
  Comment & submit:
    LLDR ca        add a comment on the line (V-select first for a range)
    LLDR sa        add a suggestion (proposed code change)
    :w             stage the comment as PENDING (not visible until submit)
    LLDR cd        delete a comment      :q!  discard an unsaved comment window
    LLDR vs        submit review -> Ctrl-a approve / Ctrl-m comment / Ctrl-r request-changes
    LLDR vd        discard the whole pending review
    Ctrl-c         close the review tab (pending comments survive; resume later)
  Threads:
    LLDR cr        reply to thread    LLDR rt / rT   resolve / unresolve
    reactions LLDR r: rp🎉 rh❤️ re👀 r+👍 r-👎 rr🚀 rl😄 rc😕

## Buffers & windows
    SPC bn / SPC bp    next / previous buffer
    SPC ] / SPC [      next / prev buffer (bufferline tabs at top)
    SPC 1..9           jump to buffer N by its ordinal in the tabline
    Ctrl-h/j/k/l      move FOCUS between splits (crosses into tmux panes)
    SPC sv / SPC sh   split vertical / horizontal
    :leftabove vsplit  split to the LEFT (default sv opens right)
    SPC h / SPC l     move split border left / right   (like tmux PFX h/l)
    SPC k / SPC j     move split border up / down      (like tmux PFX k/j)
    SPC e             toggle file explorer (nvim-tree)
  Move the window itself (uppercase = move, lowercase = focus):
    Ctrl-w H/L/K/J    move window to far left / right / top / bottom
    Ctrl-w r          rotate windows      Ctrl-w x   swap with next
    Ctrl-w = / _ / |  equalize / max height / max width
  Close:
    Ctrl-w q          close current window (:q does the same)
    Ctrl-w c          close window, keep buffer loaded
    Ctrl-w o (:only)  close all OTHER windows, keep this one
    (last window: :q quits nvim; use :only to collapse to one)

## File tree (nvim-tree, keys act on the node under the cursor)
    a       create file (end name with / to make a directory)
    d       delete            D       trash (send to macOS Trash)
    r       rename            e       rename basename only
    x       cut               c       copy            p       paste
    y       copy filename     Y       copy relative path   gy   copy absolute path
    Enter/o open              Ctrl-v  open in vertical split
    Ctrl-x  open in h-split   Ctrl-t  open in new tab   Tab   preview
    -       go up a dir       P       jump to parent   BS    close dir
    H       toggle hidden/dotfiles      I     toggle git-ignored
    E       expand all        W       collapse all     R     refresh
    f       live filter       F       clear filter     S     search
    q       close tree        g?      full help

## Fuzzy finder (fzf-lua)
    SPC ff    find files
    SPC fg    live grep (search file contents)
    SPC fb    open buffers
    SPC fh    help tags
    SPC fx    diagnostics (current document)
    SPC fX    diagnostics (whole workspace)

## LSP (active when a language server is attached)
    K          hover docs
    SPC gd     go to definition (fzf)
    SPC gD     go to definition (direct)
    SPC gS     go to definition in a vertical split
    SPC ca     code action
    SPC rn     rename symbol
    SPC oi     organize imports + format
    SPC fr     references
    SPC ft     type definitions
    SPC fs     document symbols
    SPC fw     workspace symbols
    SPC fi     implementations

## Diagnostics
    SPC d      show diagnostic under cursor (float)
    SPC D      show diagnostics for the line (float)
    SPC dl     show line diagnostics (float)
    SPC nd     jump to next diagnostic
    SPC pd     jump to previous diagnostic
    SPC q      open diagnostics in a location list
    SPC td     toggle diagnostics on/off

## Git (mini.diff / mini.git)
    ]h / [h    next / previous changed hunk
    SPC gp     toggle inline diff overlay (old vs new, in place)
    SPC ga     stage hunk (git add; operator: SPC ga + motion)
    SPC gb     git blame / show at cursor
    SPC gv     Diffview: side-by-side diff of all working-tree changes
    SPC gV     Diffview: history of the current file
    SPC gq     Diffview: close
      (in Diffview: pick a file in the left panel; ]c/[c between changes;
       tab/g? for help; :DiffviewClose or SPC gq to exit)

## Diff a file you're editing
    SPC gp                toggle inline overlay of your changes vs git HEAD
    ]h / [h               jump between changed hunks
    :Gdiff  (from shell)  git difftool % -> side-by-side old|new in nvim
    In diff view:  ]c / [c next/prev change; do get change; dp put change;
                   zo/zc open/close fold; :qa quit
    :terminal git diff %  quick unified diff of the current file (delta)

## Completion (blink.cmp, insert mode)
    Ctrl-Space   show / hide completion menu
    Ctrl-j/k     next / previous item
    Enter        accept
    Tab/Shift-Tab jump forward/back in a snippet

## Notes (obsidian, only if ~/Documents/Notes exists)
    SPC nn    new note
    SPC nf    find note
    SPC ns    search notes
    SPC nt    today's daily note
    SPC nw    switch workspace

## Floating terminal
    SPC t     toggle floating terminal
    Esc       (in terminal) leave insert -> normal mode
    Ctrl-q    (in terminal) close it

## Text objects & surround (mini.nvim)
    gc        comment (operator: gc + motion; gcc = line)    [mini.comment]
    gsa       add surround     (gsa + motion + char)         [mini.surround]
    gsd       delete surround  (gsd + char)
    gsr       replace surround (gsr + old + new)
    (surround moved to gs* so bare `s` = on-screen jump)
    ci( ca" etc + treesitter-aware a/i objects (functions, args)  [mini.ai]

## Reference
    SPC ?     open this cheat sheet
