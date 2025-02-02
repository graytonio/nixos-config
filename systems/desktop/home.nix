{ pkgs, ... }: {
  home.username = "graytonio";
  home.homeDirectory = "/home/graytonio";

  imports =
    [ 
      ../../modules/shell 
      ../../modules/programs/nvim
      ../../modules/programs/yazi
      ../../modules/gui/media
      ../../modules/gui/kitty
      ../../modules/gui/spotify
      ../../modules/gui/discord
      ../../modules/programming 
      ../../modules/gaming
      ../../modules/wm/hyprland
    ];

  xresources.properties = {
    "Xcursor.size" = 16;
    "Xft.dpi" = 172;
  };

  home.sessionVariables = {
    XCURSOR_SIZE = "24";
    HYPRCURSOR_SIZE = "24";
  };

  hyprlandMonitors = [
    "DP-1,preferred,0x0,1"
    "DP-2,preferred,-1440x-480,1,transform,1"
  ];

  
  programs.fish = {
    shellAliases = {
      nixup = "sudo nixos-rebuild switch --flake ~/nixos-config/#desktop";
    };
  };

  home.packages = with pkgs; [
    ventoy
    rocmPackages.rocm-runtime
  ];

  home.stateVersion = "24.05";
  programs.home-manager.enable = true;
}
