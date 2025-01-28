{pkgs, ...}:
{
  imports = [
     ./hyprland.nix
     ./rofi.nix
     ./hyprpanel.nix
  ];

  home.packages = with pkgs; [ 
    # Wallpaper
    swww

    # Screenshots
    grim
    slurp
    wl-clipboard

    xclicker
  ];
}
