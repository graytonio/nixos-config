{ config, pkgs, ... }: {
  programs.tmux = {
    enable = true;
    prefix = "C-Space";
    terminal = "tmux-256color";
    shell = "${pkgs.fish}/bin/fish";

    mouse = true;
    baseIndex = 1;
    historyLimit = 50000;

    plugins = with pkgs; [{
      plugin = tmuxPlugins.catppuccin;
    }];

    extraConfig = ''
      set -g allow-passthrough on
      set -g renumber-windows on

      set -ga update-environment TERM
      set -ga update-environment TERM_PROGRAM

      bind "|" split-window -h -c "#{pane_current_path}"
      bind "\\" split-window -fh -c "#{pane_current_path}"

      bind "-" split-window -v -c "#{pane_current_path}"
      bind "_" split-window -fv -c "#{pane_current_path}"

      bind -r f run-shell "tmux neww tmux-sessionizer"
      bind -r a run-shell "tmux neww tmux-android-client"

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

      set -g status-right ""
      set -ag status-right "#{E:@catppuccin_status_date_time}"
    '';
  };
}

