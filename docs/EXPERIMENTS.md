# Isolated experiment workflow

Use `NVIM_APPNAME` rather than only `nvim -u`. `NVIM_APPNAME` gives each experiment its own config, data, state and cache roots, so Lazy/Mason/parser state from the daily configuration is not accidentally reused.

## Recommended: Git worktrees

From a normal clone of this repository:

```bash
git fetch origin

git worktree add ~/.config/nvim-core origin/next/core-refresh
git worktree add ~/.config/nvim-snacks origin/exp/ui-snacks
git worktree add ~/.config/nvim-oil origin/exp/explorer-oil
git worktree add ~/.config/nvim-ime origin/exp/ime-squirrel-cli
git worktree add ~/.config/nvim-mcu origin/exp/mcu-overseer
git worktree add ~/.config/nvim-pet origin/exp/pet-companion
```

Run one configuration with:

```bash
NVIM_APPNAME=nvim-core nvim
NVIM_APPNAME=nvim-snacks nvim
NVIM_APPNAME=nvim-oil nvim
NVIM_APPNAME=nvim-ime nvim
NVIM_APPNAME=nvim-mcu nvim
NVIM_APPNAME=nvim-pet nvim
```

Each name gets independent runtime directories such as `~/.local/share/nvim-pet` and `~/.cache/nvim-pet`.

## What to judge

Do not judge an experiment by feature count. Keep it only if it reduces friction in real work.

- startup and first-use reliability
- keymap discoverability
- visual noise
- whether it replaces an existing action instead of duplicating it
- whether you reach for it naturally after several sessions
- whether removing it would actually be annoying

For explorer experiments, keep Neo-tree available while learning Oil. For Snacks, only the explicitly enabled modules should be judged; the branch intentionally does not turn Snacks into an all-in-one distribution.

## Cleanup

After removing a worktree, its isolated runtime data can also be removed:

```bash
git worktree remove ~/.config/nvim-pet
rm -rf ~/.local/share/nvim-pet ~/.local/state/nvim-pet ~/.cache/nvim-pet
```
