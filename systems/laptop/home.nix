{ config, pkgs, ... }: {
  home.username = "graytonio";
  home.homeDirectory = "/home/graytonio";

  imports =
    [ 
      ../../modules/shell 
      ../../modules/programs 
      ../../modules/gui 
      ../../modules/programming 
      ../../modules/wm/hyprland
    ];

  hyprlandMonitors = [
    "eDP-1,preferred,0x0,2"
  ];

  xresources.properties = {
    "Xcursor.size" = 16;
    "Xft.dpi" = 172;
  };

  home.sessionVariables = {
    XCURSOR_SIZE = "48";
    HYPRCURSOR_SIZE = "48";
  };

  programs.fish = {
    shellAliases = {
      nixup = "sudo nixos-rebuild switch --flake ~/nixos-config/#laptop";
    };
  };

  home.stateVersion = "24.05";
  programs.home-manager.enable = true;
}
