{pkgs, ...}:
{
  imports = [
     ./hyprland.nix
     ./eww.nix
     ./mako.nix
     ./rofi.nix
     ./waybar.nix
  ];

  home.packages = with pkgs; [ 
    # Wallpaper
    swww

    # Screenshots
    grim
    slurp
    wl-clipboard
  ];
}
