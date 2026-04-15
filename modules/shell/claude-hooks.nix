{ pkgs, lib, ... }:
let
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
  notifyWaiting = pkgs.writeShellScript "claude-notify-waiting" ''
    SESSION=$(tmux display-message -p '#S' 2>/dev/null)
    if [ -n "$SESSION" ]; then
      grep -qxF "$SESSION" "$HOME/.local/share/tmux-claude-waiting" 2>/dev/null \
        || echo "$SESSION" >> "$HOME/.local/share/tmux-claude-waiting"
      ${pkgs.terminal-notifier}/bin/terminal-notifier \
        -message "Claude is waiting for input" \
        -title "$SESSION" \
        -sound Glass \
        -execute "${clickHandler} \"$SESSION\"" 2>/dev/null
    fi
  '';
  stopHook = pkgs.writeShellScript "claude-stop-hook" ''
    LOG="$HOME/.local/share/claude-hook.log"
    mkdir -p "$HOME/.local/share"
    echo "--- stop hook fired at $(date) ---" >> "$LOG"
    SESSION=$(tmux display-message -p '#S' 2>/dev/null)
    echo "SESSION=$SESSION" >> "$LOG"
    if [ -n "$SESSION" ]; then
      grep -qxF "$SESSION" "$HOME/.local/share/tmux-claude-waiting" 2>/dev/null \
        || echo "$SESSION" >> "$HOME/.local/share/tmux-claude-waiting"
      ${pkgs.terminal-notifier}/bin/terminal-notifier \
        -message "Claude is waiting for input" \
        -title "$SESSION" \
        -sound Glass \
        -execute "${clickHandler} \"$SESSION\"" >> "$LOG" 2>&1
      echo "terminal-notifier exit: $?" >> "$LOG"
    else
      echo "SESSION empty, skipping notification" >> "$LOG"
    fi
  '';
  preToolUseHook = pkgs.writeShellScript "claude-pretooluse-hook" ''
    SESSION=$(tmux display-message -p '#S' 2>/dev/null)
    if [ -n "$SESSION" ]; then
      WAITING="$HOME/.local/share/tmux-claude-waiting"
      if [ -f "$WAITING" ]; then
        grep -vxF "$SESSION" "$WAITING" > "$WAITING.tmp"; mv "$WAITING.tmp" "$WAITING"
      fi
    fi
  '';
in {
  home.activation.claudeSettings = lib.hm.dag.entryAfter ["writeBoundary"] ''
    mkdir -p "$HOME/.claude"
    cp ${pkgs.writeText "claude-settings.json" (builtins.toJSON {
      hooks = {
        SessionStart = [{
          hooks = [{
            type = "command";
            command = "brief inject";
            timeout = 10;
            statusMessage = "Loading team standards...";
          }];
        }];
        Stop = [{
          hooks = [{ type = "command"; command = "${stopHook}"; }];
        }];
        PermissionRequest = [{
          hooks = [{ type = "command"; command = "${notifyWaiting}"; async = true; }];
        }];
        PreToolUse = [{
          hooks = [{ type = "command"; command = "${preToolUseHook}"; }];
        }];
      };
      enabledPlugins = {
        "gopls-lsp@claude-plugins-official" = true;
        "rust-analyzer-lsp@claude-plugins-official" = true;
        "typescript-lsp@claude-plugins-official" = true;
        "superpowers@claude-plugins-official" = true;
      };
      skipDangerousModePermissionPrompt = true;
    })} "$HOME/.claude/settings.json"
    chmod 644 "$HOME/.claude/settings.json"
  '';
}
