{ config, pkgs, ... }: {
  imports = [ 
    ./fish.nix 
    ./starship.nix
    ./tmux.nix
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
    neofetch
    unzip
    yt-dlp
    just
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
