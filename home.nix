{ config, pkgs, ... }:
{
  home.username = "graytonio";
  home.homeDirectory = "/home/graytonio";

  imports = [
    ./modules/shell
    ./modules/programs
    ./modules/gui
  ];

  xresources.properties = {
    "Xcursor.size" = 16;
    "Xft.dpi" = 172;
  };

  home.packages = with pkgs; [
    which
    glow    
  ];

  programs.git = {
    enable = true;
    userName = "Grayton Ward";
    userEmail = "graytonio.ward@gmail.com";
  };

  programs.alacritty = {
    enable = true;
    
    settings = {
      env.TERM = "xterm-256color";
      font = {
        size = 12;
      };
      selection.save_to_clipboard = true;
    };
  };

  home.stateVersion = "24.05";
  programs.home-manager.enable = true;
}
