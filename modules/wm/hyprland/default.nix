{pkgs, inputs, ...}:
{
  imports = [
     ./hyprland.nix
     ./rofi.nix
     ./hyprpanel.nix
  ];
  home.packages = with pkgs; [ 
    # Wallpaper Daemon
    inputs.swww.packages.${pkgs.system}.swww

    # Screenshots
    grim
    slurp
    wl-clipboard

    xclicker
  ];
}
