{ config, pkgs, ... }: {
  imports = [ 
    ./fish.nix 
    ./starship.nix
    ./tmux.nix
  ];

  home.packages = with pkgs; [ 
    which
    jq
    direnv
    dust
    rsync
    rclone
    btop
    neofetch
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
