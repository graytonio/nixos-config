{ config, pkgs, ... }: {
  imports = [
    ./fish.nix
    ./starship.nix
    ./tmux.nix
    ./claude-hooks.nix
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
