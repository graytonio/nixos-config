{ config, pkgs, ... }: {
  imports = [ ./fish.nix ./starship.nix ];

  home.packages = with pkgs; [ ripgrep jq eza fzf bat direnv ];

  home.sessionVariables = {
    BROWSER = "firefox";
    TERMINAL = "alacritty";
  };
}
