{ config, pkgs, lib, ... }: {
  imports = [
    ./fish.nix
    ./starship.nix
    ./tmux.nix
    ./claude-hooks.nix
  ];

  home.packages = with pkgs; [
    which
    jq
    terminal-notifier
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
      if [ -f "$FILE" ] && grep -q '[^[:space:]]' "$FILE" 2>/dev/null; then
        echo "● claude"
      fi
    '')
  ];

  programs.git = {
    enable = true;
    settings = {
      user.name = "Grayton Ward";
      user.email = lib.mkDefault "graytonio.ward@gmail.com";
      push.autoSetupRemote = true;
      init.defaultBranch = "main";
    };
  };

  home.sessionVariables = {
    BROWSER = "firefox";
    TERMINAL = "alacritty";
  };
}
