{pkgs, inputs, ...}:
{
  imports = [
     ./hyprland.nix
     ./rofi.nix
     ./hyprpanel.nix
  ];
  home.packages = with pkgs; [ 
    # Wallpaper Daemon
    inputs.swww.packages.${pkgs.stdenv.hostPlatform.system}.swww

    # Screenshots
    grim
    slurp
    wl-clipboard

    xclicker
  ];
}
