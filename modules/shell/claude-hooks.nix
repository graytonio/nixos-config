{ pkgs, lib, ... }:
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
