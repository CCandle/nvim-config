# Extmark companion prototype

This experiment intentionally uses **no floating window and no image layer**. The companion is rendered as right-aligned virtual text with a Neovim extmark, so it never changes the file, never appears in Git diffs, and does not own a separate window.

Current reactions:

- recent Insert-mode typing → active/typing animation
- save → short happy animation
- diagnostic error count increases → worried animation
- diagnostic errors decrease → happy animation
- long idle period → sleep animation
- cursor/buffer movement → companion follows the active editing area

Commands:

```vim
:PetToggle
:PetMood idle
:PetMood typing
:PetMood happy
:PetMood worried
:PetMood sleep
```

The Lua API also exposes:

```lua
require("core.pet").react("happy", 2000)
```

so a later Overseer/DAP integration can react to build and debug state without coupling the pet to those plugins.

## Why there is no LLM yet

The first prototype deliberately keeps movement and state transitions deterministic. A local model is only useful for sparse higher-level decisions such as mood, occasional remarks, or choosing an animation after a build/debug event. It should not sit in the animation loop.

If the basic companion survives real use without becoming distracting, the next experiment can add an optional Ollama brain with a strict low-frequency telemetry-only input (mode, idle time, diagnostics, save/build state) and no source-code upload.
