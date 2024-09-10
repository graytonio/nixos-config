{ config, pkgs, ... }: {
  home.username = "graytonio";
  home.homeDirectory = "/home/graytonio";

  imports =
    [ ./modules/shell ./modules/programs ./modules/gui ./modules/programming ];

  xresources.properties = {
    "Xcursor.size" = 16;
    "Xft.dpi" = 172;
  };

  home.packages = with pkgs; [ which glow ];

  programs.git = {
    enable = true;
    userName = "Grayton Ward";
    userEmail = "graytonio.ward@gmail.com";
  };

  home.stateVersion = "24.05";
  programs.home-manager.enable = true;
}
