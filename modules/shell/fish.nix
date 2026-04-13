{ config, pkgs, ... }: {

  home.packages = with pkgs; [
    bat
    ripgrep
    eza
    fzf
  ];

  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set fish_greeting # Disable greeting

      fish_add_path $HOME/go/bin
      fish_add_path $HOME/.local/bin
    '';
    shellAliases = {
      tarnow = "tar -acf";
      untar = "tar -zxvf";

      cat = "bat";
      grep = "rg";
      la = "eza -a --color=always --group-directories-first --icons";
      ll = "eza -l --color=always --group-directories-first --icons";
      ls = "eza -la --color=always --group-directories-first --icons";

      gc = "git commit";
      gs = "git status";
      gb = "git checkout";
      gm = "git checkout main && git pull";

      nixgc = "nix-env --delete-generations 1d && nix-store --gc";
    };
    functions = {
      tmux-sessionizer.body = ''
        set -l selection (find ~ ~/repos -mindepth 1 -maxdepth 1 -type d | fzf)
        if test -z "$selection"
          return 0
        end
        tmux-session $selection
      '';

      tmux-session.argumentNames = "selection";
      tmux-session.body = ''
        set -l selected_name (basename "$selection" | tr . _)
        set -l tmux_running (pgrep tmux)

        if test -z "$TMUX" && test -z "$tmux_running"
          tmux new-session -s $selected_name -c $selection
          return 0
        end

        if not tmux has-session -t=$selected_name 2> /dev/null
          tmux new-session -ds $selected_name -c $selection
        end

        tmux switch-client -t $selected_name
      '';

      tmux-session-picker.body = ''
        set -l waiting_file ~/.local/share/tmux-claude-waiting

        # Build pane PID -> session mapping
        set -l pane_pids (tmux list-panes -a -F "#{pane_pid}" 2>/dev/null)
        set -l pane_sessions_list (tmux list-panes -a -F "#{session_name}" 2>/dev/null)

        # Find sessions that have Claude Code running in any pane by walking
        # each claude process's parent chain until we hit a pane PID
        set -l claude_sessions
        for claude_pid in (pgrep -x claude 2>/dev/null)
          set -l pid $claude_pid
          for _i in (seq 20)
            set -l found_idx 0
            for i in (seq (count $pane_pids))
              if test "$pane_pids[$i]" = "$pid"
                set found_idx $i
                break
              end
            end
            if test $found_idx -gt 0
              set -l session $pane_sessions_list[$found_idx]
              if not contains -- $session $claude_sessions
                set -a claude_sessions $session
              end
              break
            end
            set pid (ps -p $pid -o ppid= 2>/dev/null | string trim)
            if test -z "$pid" || test "$pid" = "0" || test "$pid" = "1"
              break
            end
          end
        end

        if test (count $claude_sessions) -eq 0
          echo "No sessions with Claude Code running"
          sleep 1
          return 0
        end

        set -l selected (
          for session in $claude_sessions
            if test -f $waiting_file && grep -qx "$session" $waiting_file
              echo "● $session"
            else
              echo "  $session"
            end
          end | fzf --ansi --no-preview
        )
        test -z "$selected" && return 0
        set -l session_name (string sub -s 3 $selected)
        if test -f $waiting_file
          set -l lines (grep -v "^$session_name\$" $waiting_file 2>/dev/null)
          if test (count $lines) -gt 0
            printf "%s\n" $lines > $waiting_file
          else
            rm -f $waiting_file
          end
        end
        tmux switch-client -t $session_name
      '';

      ping_alert.argumentNames = [ "host" "interval" ];
      ping_alert.body = ''
	if test -z "$host"
        	echo "Usage: ping_alert <host> [interval_seconds]"
        	echo "Example: ping_alert google.com 5"
        	return 1
    	end
 
    	echo "⏳ Waiting for $host to respond... (checking every {$interval}s)"
 
    	while true
        	if ping -c 1 -W 1000 $host > /dev/null 2>&1
            		osascript -e "display alert \"Server Online 🟢\" message \"$host is now reachable!\""
            		echo "✅ $host is responding!"
            		return 0
        	else
            		echo "❌ No response from $host — retrying in {$interval}s..."
            		sleep $interval
        	end
    	end
      '';

      tmux-android-client.body = ''
	set -l SESSION_NAME "android"
	set -l COMMAND "waydroid show-full-ui"

	tmux-session $SESSION_NAME

	set -l WINDOW_IDEX 1
	set -l WINDOW_IDEX (tmux list-windows -t $SESSION_NAME -F "#{window_index}:#{window_name}" | grep "^$WINDOW_INDEX:" | cut -d: -f2)

	if not tmux list-panes -t "$SESSION_NAME:$WINDOW_NAME" -F "#{pane_title}" | grep -q "$COMMAND"
          tmux send-keys -t "$SESSION_NAME:$WINDOW_INDEX" "$COMMAND" Enter
        end
      '';

      clone = {
        argumentNames = "repo";
        body = ''
          set -l repo_name (basename $repo .git)
          git clone $repo ~/repos/$repo_name
        '';
      };

      envsource = {
	argumentNames = "file";
	body = ''
	  eval (cat $file | sed -E 's/(.*)=(.*)/set -x \1 \2;/')
	'';
      };

      gac = {
      	body = ''
    # Check if there are staged changes
    set -l staged_diff (git diff --cached)
    
    if test -z "$staged_diff"
        echo "Error: No staged changes found. Stage your changes with 'git add' first."
        return 1
    end

    # Get list of staged files for context
    set -l staged_files (git diff --cached --name-only)
    
    echo "Staged files:"
    for file in $staged_files
        echo "  - $file"
    end
    echo ""
    echo "Generating commit message..."

    # Build the prompt
    set -l prompt "You are a helpful assistant that writes concise git commit messages.
Based on the following git diff of staged changes, write a short, clear commit message.
Follow conventional commit format if appropriate (e.g., feat:, fix:, docs:, refactor:, etc.).
Only output the commit message itself, nothing else. Keep it under 72 characters if possible.

Staged files:
$staged_files

Diff:
$staged_diff"

    # Call ollama to generate the commit message
    set -l commit_msg (echo $prompt | ollama run --think=false qwen3:8b 2>/dev/null)
    
    if test -z "$commit_msg"
        echo "Error: Failed to generate commit message from ollama."
        echo "Make sure ollama is running and the model is available."
        return 1
    end

    # Clean up the message (remove leading/trailing whitespace and quotes)
    set commit_msg (string trim $commit_msg)
    set commit_msg (string trim --chars='"' $commit_msg)
    
    echo "Generated commit message:"
    echo "  \"$commit_msg\""
    echo ""
    
    # Ask for confirmation
    read -l -P "Commit with this message? [Y/n/e(dit)] " confirm
    
    switch $confirm
        case \'\' Y y yes Yes
            git commit -m "$commit_msg"
            echo "✓ Changes committed!"
        case e E edit Edit
            # Let user edit the message
            read -l -P "Enter your commit message: " custom_msg
            if test -n "$custom_msg"
                git commit -m "$custom_msg"
                echo "✓ Changes committed with custom message!"
            else
                echo "Aborted: No message provided."
                return 1
            end
        case '*'
            echo "Commit aborted."
            return 1
    end
	'';
      };
    };
  };
}

