{pkgs, ...}:
{
  imports = [
     ./hyprland.nix
     ./mako.nix
     ./rofi.nix
     ./waybar.nix
  ];

  home.packages = with pkgs; [ 
    # Widget Engine
    eww

    # Wallpaper
    swww

    # Screenshots
    grim
    slurp
    wl-clipboard
  ];
}
