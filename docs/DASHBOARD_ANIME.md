# Anime Dashboard — exp/dashboard-anime

A visual-first Neovim start screen built on the existing folke/snacks.nvim dashboard.

## Design

- Wide terminals use two panes: an animated illustration on the left, and shortcuts / recent files / projects on the right.
- Narrow terminals fall back to a single-column layout.
- The header shows a time-aware greeting and local date.
- Existing Telescope pickers and persistence.nvim are reused; no second picker or session manager is introduced.
- The classic dashboard-nvim and Snacks dashboard are mutually exclusive through settings.ui.dashboard.

## Animated artwork

assets/dashboard/yoru-desk.gif is an original, locally stored 4-second loop (8 frames at 500 ms per frame). It is rendered by Chafa as ANSI/Unicode half-block symbols inside Snacks' terminal section.

Install the optional renderer on macOS:

    brew install chafa

The command forces the symbols output format, so it does not depend on iTerm2's native image protocol, Kitty graphics, or Sixel support. Terminal capability probing is disabled to avoid a startup delay.

If Chafa or the GIF is missing, the dashboard uses a small built-in text fallback. The rest of the dashboard remains fully functional. No network request is made when Neovim starts.

The animation uses ttl = 0, so Snacks does not cache its live terminal output as a still frame. Snacks owns the terminal job and stops it when the dashboard closes or refreshes.

## Use

From a worktree checkout:

    NVIM_APPNAME=nvim-dashboard nvim

- <leader>h: open the dashboard
- f: find file
- g: live grep
- r: recent files
- n: new file
- c: browse the Neovim config
- s: restore a persistence session
- l: Lazy
- q: quit

Recent projects are listed separately and open through the existing Snacks project picker behavior.

## Validation checklist

1. Open the branch with NVIM_APPNAME=nvim-dashboard.
2. Confirm the animated panel appears on a wide terminal.
3. Confirm the single-column layout appears when the terminal is narrower than 92 columns.
4. Confirm f, g, r, n, c, s, and q still perform their advertised actions.
5. Confirm the dashboard remains usable when chafa is unavailable.
6. Close the dashboard and verify the Chafa process is gone with pgrep -fl chafa.
7. Run :checkhealth snacks.

This experiment adds no plugin dependency and does not modify lazy-lock.json.
