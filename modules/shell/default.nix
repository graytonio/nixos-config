{ config, pkgs, ... }: {
  imports = [ ./fish.nix ./starship.nix ./yazi.nix ];

  home.packages = with pkgs; [ ripgrep jq eza fzf bat direnv dust rsync rclone ];

  home.sessionVariables = {
    BROWSER = "firefox";
    TERMINAL = "alacritty";
  };
}
