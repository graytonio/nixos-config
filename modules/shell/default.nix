{ config, pkgs, ... }: {
  imports = [ ./fish.nix ./starship.nix ./yazi.nix ];

  home.packages = with pkgs; [ 
    which
    ripgrep 
    jq 
    eza 
    fzf 
    bat 
    direnv 
    dust 
    rsync 
    rclone
  ];

  programs.git = {
    enable = true;
    userName = "Grayton Ward";
    userEmail = "graytonio.ward@gmail.com";
  };


  home.sessionVariables = {
    BROWSER = "firefox";
    TERMINAL = "alacritty";
  };
}
