# tmux Claude Flow Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a fzf session-switcher popup and Claude Code waiting notifications (macOS + tmux status bar) to the existing NixOS tmux/fish config.

**Architecture:** Three independent components sharing a plain-text state file (`~/.local/share/tmux-claude-waiting`). Claude Code hooks write session names to the file on pause/resume; the fzf popup and status bar script read it. No background daemons.

**Tech Stack:** Nix (home-manager), tmux, fish shell, fzf, Claude Code hooks, osascript (macOS)

---

## File Map

| Action | Path | Responsibility |
|--------|------|----------------|
| Modify | `modules/shell/tmux.nix` | Add `Space` bind, `status-interval`, status-right entry |
| Modify | `modules/shell/fish.nix` | Add `tmux-session-picker` function |
| Modify | `modules/shell/default.nix` | Add claude-hooks import + status script package |
| Create | `modules/shell/claude-hooks.nix` | Manage `~/.claude/settings.json` with Stop/PreToolUse hooks |

---

## Task 1: tmux Status Bar Indicator

Add a shell script that outputs `● claude` when any sessions are waiting, and wire it into the tmux status bar.

**Files:**
- Modify: `modules/shell/default.nix`
- Modify: `modules/shell/tmux.nix`

- [ ] **Step 1: Add tmux-claude-status script to default.nix**

Open `modules/shell/default.nix`. Add a `pkgs.writeShellScriptBin` derivation to `home.packages`:

```nix
{ config, pkgs, ... }: {
  imports = [ 
    ./fish.nix 
    ./starship.nix
    ./tmux.nix
  ];

  home.packages = with pkgs; [ 
    which
    jq
    yq-go
    direnv
    dust
    rsync
    rclone
    btop
    unzip
    yt-dlp
    just
    (writeShellScriptBin "tmux-claude-status" ''
      FILE="$HOME/.local/share/tmux-claude-waiting"
      if [ -f "$FILE" ] && [ -s "$FILE" ]; then
        echo "● claude"
      fi
    '')
  ];

  programs.git.settings = {
    enable = true;
    user.name = "Grayton Ward";
    user.email = "graytonio.ward@gmail.com";
  };

  home.sessionVariables = {
    BROWSER = "firefox";
    TERMINAL = "alacritty";
  };
}
```

- [ ] **Step 2: Wire status script into tmux.nix**

Open `modules/shell/tmux.nix`. Add `status-interval` and the `tmux-claude-status` call to `status-right`, before the date:

```nix
set -g status-interval 2

set -g status-right ""
set -ag status-right "#(tmux-claude-status)"
set -ag status-right "#{E:@catppuccin_status_date_time}"
```

The full `extraConfig` block in `tmux.nix` should look like:

```nix
extraConfig = ''
  set -g allow-passthrough on
  set -g renumber-windows on
  set -ga terminal-features ",*:hyperlinks"

  set -ga update-environment TERM
  set -ga update-environment TERM_PROGRAM

  bind "|" split-window -h -c "#{pane_current_path}"
  bind "\\" split-window -fh -c "#{pane_current_path}"

  bind "-" split-window -v -c "#{pane_current_path}"
  bind "_" split-window -fv -c "#{pane_current_path}"

  bind -r f run-shell "tmux neww tmux-sessionizer"
  bind -r s run-shell "tmux neww slack-tui"

  bind h select-pane -L
  bind j select-pane -D
  bind k select-pane -U
  bind l select-pane -R

  set -gu default-command
  set -g default-shell "$SHELL"

  set -g status-right-length 100
  set -g status-left-length 100

  set -g @catppuccin_window_default_text '#W'
  set -g @catppuccin_window_current_text '#W'
  set -g @catppuccin_window_text " #W"

  set -g status-left ""
  set -ag status-left "#{E:@catppuccin_status_session}"

  set -g status-interval 2

  set -g status-right ""
  set -ag status-right "#(tmux-claude-status)"
  set -ag status-right "#{E:@catppuccin_status_date_time}"
'';
```

- [ ] **Step 3: Build to verify no syntax errors**

```bash
darwin-rebuild build --flake ~/repos/nixos-config/#work
```

Expected: build completes with no errors. If you see `error: undefined variable 'writeShellScriptBin'`, confirm `pkgs` is in scope in `default.nix` (it should be via `{ config, pkgs, ... }:`).

- [ ] **Step 4: Switch and verify**

```bash
nixup
```

Then in a new tmux session, run:

```bash
tmux-claude-status
```

Expected: no output (state file doesn't exist yet). Then manually create the state file and re-run:

```bash
echo "test-session" > ~/.local/share/tmux-claude-waiting
tmux-claude-status
```

Expected output: `● claude`

Clean up:

```bash
rm ~/.local/share/tmux-claude-waiting
```

Also verify the tmux status bar updates (wait ~2 seconds after creating/removing the file).

- [ ] **Step 5: Commit**

```bash
git add modules/shell/default.nix modules/shell/tmux.nix
git commit -m "feat: add tmux status bar indicator for claude waiting sessions"
```

---

## Task 2: Session Switcher Popup

Add the `tmux-session-picker` fish function and bind `C-Space Space` to open it as a popup.

**Files:**
- Modify: `modules/shell/fish.nix`
- Modify: `modules/shell/tmux.nix`

- [ ] **Step 1: Add tmux-session-picker to fish.nix**

Open `modules/shell/fish.nix`. Add `tmux-session-picker` to the `functions` attrset inside `programs.fish`:

```nix
tmux-session-picker.body = ''
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
  set -l session_name (string sub -s 3 $selected)
  sed -i "" "/^$session_name\$/d" $waiting_file 2>/dev/null
  tmux switch-client -t $session_name
'';
```

Place it alongside the existing `tmux-sessionizer` and `tmux-session` functions. The `string sub -s 3` strips the two-character prefix (`● ` or `  `) regardless of badge state.

- [ ] **Step 2: Add Space bind to tmux.nix**

Open `modules/shell/tmux.nix`. Add this line to `extraConfig`, after the existing `bind -r s` line:

```nix
bind Space display-popup -E -w 40 -h 20 "fish -c tmux-session-picker"
```

`display-popup -E` closes the popup automatically when the fish function exits. `-w 40 -h 20` gives it a comfortable size.

- [ ] **Step 3: Build to verify**

```bash
darwin-rebuild build --flake ~/repos/nixos-config/#work
```

Expected: build completes with no errors.

- [ ] **Step 4: Switch and verify**

```bash
nixup
```

Press `C-Space Space` — a popup should appear listing your current tmux sessions. Use arrow keys or click with mouse to select. Verify:

- Popup opens
- Sessions are listed with two-space prefix
- Selecting a session switches to it and closes the popup
- Pressing Escape closes the popup without switching

Then test the badge. From any shell:

```bash
echo "$(tmux display-message -p '#S')" > ~/.local/share/tmux-claude-waiting
```

Open the popup again — the current session should now show `●` prefix.

Clean up:

```bash
rm ~/.local/share/tmux-claude-waiting
```

- [ ] **Step 5: Commit**

```bash
git add modules/shell/fish.nix modules/shell/tmux.nix
git commit -m "feat: add tmux session picker popup with claude waiting badges"
```

---

## Task 3: Claude Code Hooks

Create `claude-hooks.nix` to manage `~/.claude/settings.json` with Stop and PreToolUse hooks that update the state file and send macOS notifications.

**Files:**
- Create: `modules/shell/claude-hooks.nix`
- Modify: `modules/shell/default.nix`

- [ ] **Step 1: Check for existing ~/.claude/settings.json**

```bash
cat ~/.claude/settings.json 2>/dev/null || echo "no existing file"
```

If the file exists and has content beyond `{}`, copy any existing settings — you'll need to merge them into the nix config in Step 2. The `home.file` approach will overwrite the file on each `nixup`.

- [ ] **Step 2: Create modules/shell/claude-hooks.nix**

```nix
{ pkgs, ... }:
let
  stopHook = pkgs.writeShellScript "claude-stop-hook" ''
    SESSION=$(tmux display-message -p '#S' 2>/dev/null)
    if [ -n "$SESSION" ]; then
      mkdir -p "$HOME/.local/share"
      grep -qxF "$SESSION" "$HOME/.local/share/tmux-claude-waiting" 2>/dev/null \
        || echo "$SESSION" >> "$HOME/.local/share/tmux-claude-waiting"
      osascript -e "display notification \"Claude is waiting\" with title \"$SESSION\""
    fi
  '';
  preToolUseHook = pkgs.writeShellScript "claude-pretooluse-hook" ''
    SESSION=$(tmux display-message -p '#S' 2>/dev/null)
    if [ -n "$SESSION" ]; then
      sed -i "" "/^$SESSION\$/d" "$HOME/.local/share/tmux-claude-waiting" 2>/dev/null
    fi
  '';
in {
  home.file.".claude/settings.json".text = builtins.toJSON {
    hooks = {
      Stop = [{
        hooks = [{ type = "command"; command = "${stopHook}"; }];
      }];
      PreToolUse = [{
        hooks = [{ type = "command"; command = "${preToolUseHook}"; }];
      }];
    };
  };
}
```

If you have existing `~/.claude/settings.json` content from Step 1, add those keys alongside `hooks` in the `builtins.toJSON { ... }` attrset.

- [ ] **Step 3: Add import to default.nix**

Open `modules/shell/default.nix`. Add `./claude-hooks.nix` to the imports list:

```nix
imports = [ 
  ./fish.nix 
  ./starship.nix
  ./tmux.nix
  ./claude-hooks.nix
];
```

- [ ] **Step 4: Build to verify**

```bash
darwin-rebuild build --flake ~/repos/nixos-config/#work
```

Expected: build completes. The hook scripts will be in the nix store as `/nix/store/<hash>-claude-stop-hook` and `/nix/store/<hash>-claude-pretooluse-hook`.

- [ ] **Step 5: Switch and verify the settings file**

```bash
nixup
cat ~/.claude/settings.json
```

Expected output (hashes will differ):

```json
{
  "hooks": {
    "PreToolUse": [{"hooks": [{"command": "/nix/store/...-claude-pretooluse-hook", "type": "command"}]}],
    "Stop": [{"hooks": [{"command": "/nix/store/...-claude-stop-hook", "type": "command"}]}]
  }
}
```

- [ ] **Step 6: End-to-end test**

Open a new tmux session named `test`:

```bash
tmux new-session -s test
```

Inside that session, run Claude Code and let it complete a turn (it will pause waiting for your input). Verify:

1. A macOS notification appears with title `test` and message `Claude is waiting`
2. `cat ~/.local/share/tmux-claude-waiting` contains `test`
3. The tmux status bar shows `● claude`
4. `C-Space Space` shows `● test` in the popup

Then respond to Claude (triggering `PreToolUse`). Verify:

1. `cat ~/.local/share/tmux-claude-waiting` is now empty
2. Status bar no longer shows `● claude`

- [ ] **Step 7: Commit**

```bash
git add modules/shell/claude-hooks.nix modules/shell/default.nix
git commit -m "feat: add claude code hooks for waiting notifications and state tracking"
```
