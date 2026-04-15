# Notification Click → Tmux Session Switch Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a `claude-notification-click` script to `claude-hooks.nix` so clicking a Claude waiting notification switches the most recently active tmux client to the notifying session.

**Architecture:** A single new `pkgs.writeShellScript` (`claude-notification-click`) is added to `modules/shell/claude-hooks.nix`. It resolves the most recently active tmux client using `tmux list-clients` sorted by activity timestamp, then calls `tmux switch-client -c <client> -t <session>`. Both existing notification scripts (`notifyWaiting` and `stopHook`) gain a `-execute` flag that invokes this script with the session name baked in at notification-send time.

**Tech Stack:** Nix (nix-darwin + home-manager), bash (shell scripts), tmux, terminal-notifier

---

## Files

- **Modify:** `modules/shell/claude-hooks.nix` — add `clickHandler` script definition; update `notifyWaiting` and `stopHook` to pass `-execute`

---

### Task 1: Write and manually test the click-handler script

No Nix involved yet — write the script directly and verify the logic works against a live tmux session.

**Files:**
- Create (temporary): `/tmp/claude-notification-click` (deleted after task)

- [ ] **Step 1: Create the script at `/tmp/claude-notification-click`**

```bash
cat > /tmp/claude-notification-click << 'EOF'
#!/usr/bin/env bash
SESSION="$1"
if [ -z "$SESSION" ]; then
  exit 0
fi
CLIENT=$(tmux list-clients -F "#{client_activity} #{client_name}" 2>/dev/null \
  | sort -rn | head -1 | awk '{print $2}')
if [ -n "$CLIENT" ]; then
  tmux switch-client -c "$CLIENT" -t "$SESSION"
fi
EOF
chmod +x /tmp/claude-notification-click
```

- [ ] **Step 2: Test with a valid session name**

Requires tmux to be running. Check the current session name:

```bash
tmux display-message -p '#S'
```

Note the output (e.g., `nixos-config`). Then run the script targeting that session:

```bash
/tmp/claude-notification-click "$(tmux display-message -p '#S')"
```

Expected: command exits 0 with no output. The active tmux client stays on the same session (switching to the already-current session is a no-op visually but confirms the code path works). Confirm with:

```bash
echo $?
```

Expected output: `0`

- [ ] **Step 3: Test with no arguments (guard condition)**

```bash
/tmp/claude-notification-click
echo "exit code: $?"
```

Expected output: `exit code: 0` (silent exit, no crash)

- [ ] **Step 4: Test with a non-existent session (graceful failure)**

```bash
/tmp/claude-notification-click "this-session-does-not-exist-xyz"
echo "exit code: $?"
```

Expected: exit code is non-zero (tmux returns an error) but the script does not crash with an unhandled error. If you see `can't find session: this-session-does-not-exist-xyz` on stderr, that is acceptable — tmux prints it, not the script. Exit code will be non-zero; that is fine.

- [ ] **Step 5: Clean up the temp file**

```bash
rm /tmp/claude-notification-click
```

---

### Task 2: Add `clickHandler` script to `claude-hooks.nix`

**Files:**
- Modify: `modules/shell/claude-hooks.nix`

- [ ] **Step 1: Open `modules/shell/claude-hooks.nix` and locate the `let` block**

The file opens with:
```nix
{ pkgs, lib, ... }:
let
  notifyWaiting = pkgs.writeShellScript ...
  stopHook = pkgs.writeShellScript ...
  preToolUseHook = pkgs.writeShellScript ...
in {
```

- [ ] **Step 2: Add `clickHandler` as the first binding in the `let` block (before `notifyWaiting`)**

Insert this block immediately after `let`:

```nix
  clickHandler = pkgs.writeShellScript "claude-notification-click" ''
    SESSION="$1"
    if [ -z "$SESSION" ]; then
      exit 0
    fi
    CLIENT=$(tmux list-clients -F "#{client_activity} #{client_name}" 2>/dev/null \
      | sort -rn | head -1 | awk '{print $2}')
    if [ -n "$CLIENT" ]; then
      tmux switch-client -c "$CLIENT" -t "$SESSION"
    fi
  '';
```

- [ ] **Step 3: Verify the file still parses**

```bash
nix-instantiate --parse modules/shell/claude-hooks.nix
```

Expected: prints the parsed AST (a large nix expression) with no errors. Any `error:` line means a syntax problem — fix before continuing.

- [ ] **Step 4: Commit**

```bash
git add modules/shell/claude-hooks.nix
git commit -m "feat: add claude-notification-click script to claude-hooks.nix"
```

---

### Task 3: Wire `-execute` into `notifyWaiting`

**Files:**
- Modify: `modules/shell/claude-hooks.nix`

- [ ] **Step 1: Find the `terminal-notifier` call inside `notifyWaiting`**

It currently looks like:

```bash
${pkgs.terminal-notifier}/bin/terminal-notifier \
  -message "Claude is waiting for input" \
  -title "$SESSION" \
  -sound Glass 2>/dev/null
```

- [ ] **Step 2: Add `-execute` flag**

Replace those lines with:

```bash
${pkgs.terminal-notifier}/bin/terminal-notifier \
  -message "Claude is waiting for input" \
  -title "$SESSION" \
  -sound Glass \
  -execute "${clickHandler} \"$SESSION\"" 2>/dev/null
```

Note: the double-quotes around `$SESSION` inside the single-quoted Nix string are literal bash double-quotes, so the session name is passed as a single argument even if it contains spaces.

- [ ] **Step 3: Verify the file still parses**

```bash
nix-instantiate --parse modules/shell/claude-hooks.nix
```

Expected: no errors.

- [ ] **Step 4: Commit**

```bash
git add modules/shell/claude-hooks.nix
git commit -m "feat: wire notification click handler into notifyWaiting"
```

---

### Task 4: Wire `-execute` into `stopHook`

**Files:**
- Modify: `modules/shell/claude-hooks.nix`

- [ ] **Step 1: Find the `terminal-notifier` call inside `stopHook`**

It currently looks like (with log redirect):

```bash
${pkgs.terminal-notifier}/bin/terminal-notifier \
  -message "Claude is waiting for input" \
  -title "$SESSION" \
  -sound Glass >> "$LOG" 2>&1
```

- [ ] **Step 2: Add `-execute` flag before the log redirect**

Replace those lines with:

```bash
${pkgs.terminal-notifier}/bin/terminal-notifier \
  -message "Claude is waiting for input" \
  -title "$SESSION" \
  -sound Glass \
  -execute "${clickHandler} \"$SESSION\"" >> "$LOG" 2>&1
```

- [ ] **Step 3: Verify the file still parses**

```bash
nix-instantiate --parse modules/shell/claude-hooks.nix
```

Expected: no errors.

- [ ] **Step 4: Commit**

```bash
git add modules/shell/claude-hooks.nix
git commit -m "feat: wire notification click handler into stopHook"
```

---

### Task 5: Build and deploy

**Files:** none changed — build only

- [ ] **Step 1: Build the darwin configuration**

From the repo root:

```bash
darwin-rebuild switch --flake .#work
```

Expected: build completes, home-manager activation runs, no errors. Watch for any Nix evaluation errors referencing `claude-hooks.nix`.

If the build fails with a Nix evaluation error, check the error message — it will point to the line number in `claude-hooks.nix`. Common causes: mismatched quotes, missing semicolons, wrong interpolation syntax.

- [ ] **Step 2: Verify the settings file was updated**

```bash
cat ~/.claude/settings.json | python3 -m json.tool | grep -A5 "Stop"
```

Expected: the `Stop` hook command should be the path to the generated `claude-stop-hook` store path. The file itself is a shell script — confirm it contains the `-execute` flag:

```bash
cat $(cat ~/.claude/settings.json | python3 -c "import sys,json; d=json.load(sys.stdin); print(d['hooks']['Stop'][0]['hooks'][0]['command'])")
```

Expected output: the `stopHook` script contents, which should contain `-execute` and the path to `claude-notification-click`.

---

### Task 6: Smoke test end-to-end

- [ ] **Step 1: Confirm you have an active tmux session**

```bash
tmux list-sessions
tmux list-clients
```

Both should show output. Note the session name shown in `list-sessions`.

- [ ] **Step 2: Trigger a Claude notification manually**

In a Claude Code session (inside tmux), cause a Stop event — the simplest way is to finish a Claude response naturally. Alternatively, trigger the hook script directly:

```bash
# Find the path to the stop hook
cat ~/.claude/settings.json | python3 -c "import sys,json; d=json.load(sys.stdin); print(d['hooks']['Stop'][0]['hooks'][0]['command'])"
```

Run it:

```bash
bash <the-path-from-above>
```

Expected: a macOS notification appears with the session name as its title.

- [ ] **Step 3: Click the notification**

Click the notification (not "dismiss" — click the body of it).

Expected: the active tmux client switches to the Claude session. If you are already on that session, nothing visible happens — in that case, switch to a different tmux session first, then trigger the notification, then click it and verify the switch back occurs.
