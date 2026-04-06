# tmux Claude Flow Design

**Date:** 2026-04-06
**Goal:** Bring two key cmux features into the existing tmux + fish NixOS setup: a toggleable session switcher popup with mouse support, and notifications when a Claude Code session is paused waiting for input.

---

## Overview

Two independent features wired together via a shared state file:

1. **Session switcher popup** — fzf popup toggled by `C-Space Space`, mouse-clickable, shows badges on sessions where Claude is waiting
2. **Claude Code notifications** — hooks fire on Claude pause/resume, writing state to disk and sending macOS notifications

---

## Component 1: Session Switcher Popup

### Behavior

- `C-Space Space` opens a `tmux display-popup` running fzf with the list of current tmux sessions
- Sessions present in `~/.local/share/tmux-claude-waiting` are prefixed with `●`
- Sessions not waiting are prefixed with two spaces for alignment
- Mouse support via fzf `--mouse` flag — click to select
- On selection: switch to that session, remove it from the waiting state file, popup auto-closes
- On cancel (Escape/q): popup closes, no switch

### Example display

```
● monorepo
  apollo-argo
  scratch
```

### Implementation

New fish function `tmux-session-picker` in `modules/shell/fish.nix`:

```fish
function tmux-session-picker
  set -l waiting_file ~/.local/share/tmux-claude-waiting
  set -l selected (
    tmux list-sessions -F "#{session_name}" | while read session
      if test -f $waiting_file && grep -qx $session $waiting_file
        echo "● $session"
      else
        echo "  $session"
      end
    end | fzf --ansi --mouse --no-preview
  )
  test -z "$selected" && return 0
  set -l session_name (string trim $selected | string replace -r '^● ' '')
  sed -i "" "/^$session_name\$/d" $waiting_file 2>/dev/null
  tmux switch-client -t $session_name
end
```

Bound in `modules/shell/tmux.nix`:

```nix
bind Space run-shell "fish -c tmux-session-picker"
```

---

## Component 2: Claude Code Hooks & State Management

### State file

`~/.local/share/tmux-claude-waiting` — plain text, one tmux session name per line. Created on first write. Readable by fzf popup and status bar script.

### Session name detection

Claude Code hooks run in the shell environment of the Claude process, which inherits tmux's `$TMUX` env variable. The session name is extracted with:

```sh
tmux display-message -p '#S'
```

### Stop hook (Claude pauses for input)

Configured in `~/.claude/settings.json` under `hooks.Stop`:

```sh
SESSION=$(tmux display-message -p '#S' 2>/dev/null)
if [ -n "$SESSION" ]; then
  mkdir -p ~/.local/share
  grep -qxF "$SESSION" ~/.local/share/tmux-claude-waiting 2>/dev/null \
    || echo "$SESSION" >> ~/.local/share/tmux-claude-waiting
  osascript -e "display notification \"Claude is waiting\" with title \"$SESSION\""
fi
```

### PreToolUse hook (Claude resumes work)

Configured in `~/.claude/settings.json` under `hooks.PreToolUse`:

```sh
SESSION=$(tmux display-message -p '#S' 2>/dev/null)
if [ -n "$SESSION" ]; then
  sed -i "" "/^$SESSION\$/d" ~/.local/share/tmux-claude-waiting 2>/dev/null
fi
```

### NixOS config

New file `modules/shell/claude-hooks.nix` uses `pkgs.writeShellScript` to put the hook scripts in the nix store, then embeds their paths into `~/.claude/settings.json` via `home.file`:

```nix
{ pkgs, ... }:
let
  stopHook = pkgs.writeShellScript "claude-stop-hook" ''
    SESSION=$(tmux display-message -p '#S' 2>/dev/null)
    if [ -n "$SESSION" ]; then
      mkdir -p ~/.local/share
      grep -qxF "$SESSION" ~/.local/share/tmux-claude-waiting 2>/dev/null \
        || echo "$SESSION" >> ~/.local/share/tmux-claude-waiting
      osascript -e "display notification \"Claude is waiting\" with title \"$SESSION\""
    fi
  '';
  preToolUseHook = pkgs.writeShellScript "claude-pretooluse-hook" ''
    SESSION=$(tmux display-message -p '#S' 2>/dev/null)
    if [ -n "$SESSION" ]; then
      sed -i "" "/^$SESSION\$/d" ~/.local/share/tmux-claude-waiting 2>/dev/null
    fi
  '';
in {
  home.file.".claude/settings.json".text = builtins.toJSON {
    hooks = {
      Stop = [{ hooks = [{ type = "command"; command = "${stopHook}"; }]; }];
      PreToolUse = [{ hooks = [{ type = "command"; command = "${preToolUseHook}"; }]; }];
    };
  };
}
```

Imported in `modules/shell/default.nix`.

---

## Component 3: tmux Status Bar

### Behavior

- Status bar polls every 2 seconds (`status-interval 2`)
- If `~/.local/share/tmux-claude-waiting` is non-empty: shows `● claude` in status-right
- If empty or absent: shows nothing

### Implementation

Shell script `tmux-claude-status`:

```sh
#!/bin/sh
FILE=~/.local/share/tmux-claude-waiting
if [ -f "$FILE" ] && [ -s "$FILE" ]; then
  echo "● claude"
fi
```

Wired into `modules/shell/tmux.nix`:

```nix
set -g status-interval 2
set -ag status-right "#(tmux-claude-status)"
```

The script is added to `home.packages` via `pkgs.writeShellScriptBin "tmux-claude-status"` so it lands on `$PATH` and tmux can call it directly.

---

## Config Structure Changes

| File | Change |
|------|--------|
| `modules/shell/tmux.nix` | Add `Space` bind, `status-interval 2`, `tmux-claude-status` in status-right |
| `modules/shell/fish.nix` | Add `tmux-session-picker` function |
| `modules/shell/claude-hooks.nix` | New file — manages `~/.claude/settings.json` via `home.file` |
| `modules/shell/default.nix` | Add `claude-hooks.nix` to imports; add `tmux-claude-status` script to packages |

---

## Assumptions & Constraints

- Claude Code is run inside tmux sessions (the `$TMUX` env var must be present for hooks to detect the session name)
- The user runs one Claude Code instance per tmux session (session name is sufficient as a key)
- `~/.claude/settings.json` is not managed outside of NixOS config (home.file will own it)
- macOS only for the `osascript` notification; the rest is platform-agnostic
