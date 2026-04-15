# Notification Click → Tmux Session Switch

**Date:** 2026-04-15  
**Status:** Approved

## Problem

When Claude sends a macOS notification (via `terminal-notifier`) to indicate it is waiting for input, the user must manually open the tmux session picker (`C-Space Space`) to navigate to the right session. Clicking the notification does nothing useful.

## Goal

Clicking a Claude waiting notification switches the most recently active tmux client to the notifying session — no terminal focus change, no extra keystrokes.

## Out of Scope

- Bringing the terminal window to the foreground (user chose option A)
- Any changes to tmux keybindings, status bar, or the session picker

## Design

### New script: `claude-notification-click`

A `pkgs.writeShellScript` defined in `modules/shell/claude-hooks.nix`, alongside the existing hook scripts.

**Inputs:** `$1` — tmux session name  
**Behavior:**
1. Query tmux for all clients and their last activity time: `tmux list-clients -F "#{client_activity} #{client_name}"`
2. Sort descending by activity, take the first result's client name
3. If a client is found, run `tmux switch-client -c "$CLIENT" -t "$1"`
4. If no client is found (tmux not running or no attached clients), exit silently

### Updated notification scripts

Both `notifyWaiting` and `stopHook` in `claude-hooks.nix` gain a `-execute` flag on their `terminal-notifier` invocations:

```bash
terminal-notifier \
  -message "Claude is waiting for input" \
  -title "$SESSION" \
  -sound Glass \
  -execute "${clickHandler} \"$SESSION\""
```

`$SESSION` is already in scope in both scripts. `$clickHandler` is the Nix store path of the new script (same pattern as how `${stopHook}` and `${notifyWaiting}` are referenced).

### No other changes

- `tmux.nix` — unchanged
- `fish.nix` — unchanged  
- `PreToolUse` hook — unchanged

## Architecture

```
terminal-notifier (click event)
  └─▶ claude-notification-click "$SESSION"
        ├─ tmux list-clients → pick most recently active client
        └─ tmux switch-client -c "$CLIENT" -t "$SESSION"
```

## Error Handling

- No tmux clients: script exits silently (no crash, notification click is a no-op)
- Session no longer exists: `tmux switch-client` will fail silently (tmux returns non-zero, script exits)
- Empty `$1`: guarded by checking that `$SESSION` is non-empty before the notification is sent (existing behavior in both hook scripts)
