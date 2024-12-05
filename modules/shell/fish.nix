{ config, pkgs, ... }: {
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set fish_greeting # Disable greeting

      fish_add_path $HOME/go/bin
    '';
    shellAliases = {
      tarnow = "tar -acf";
      untar = "tar -zxvf";

      cat = "bat";
      grep = "rg";
      la = "eza -a --color=always --group-directories-first --icons";
      ll = "eza -l --color=always --group-directories-first --icons";
      ls = "eza -la --color=always --group-directories-first --icons";

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
    };
  };
}

