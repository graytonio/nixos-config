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
    unzip
    yt-dlp
    just
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
