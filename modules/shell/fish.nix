{ config, pkgs, ... }: {
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set fish_greeting # Disable greeting
    '';
    shellAliases = {
      tarnow = "tar -acf";
      untar = "tar -zxvf";

      cat = "bat";
      grep = "rg";
      la = "eza -a --color=always --group-directories-first --icons";
      ll = "eza -l --color=always --group-directories-first --icons";
      ls = "eza -la --color=always --group-directories-first --icons";
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

      clone = {
        argumentNames = "repo";
        body = ''
          set -l repo_name (basename $repo .git)
          git clone $repo ~/repos/$repo_name
        '';
      };
    };
  };
}

