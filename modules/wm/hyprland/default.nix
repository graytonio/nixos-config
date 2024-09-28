{pkgs, lib, config, ...}:
{
  options = {
    hyprlandMonitors = lib.mkOption {
      default = [
        ",preferred,auto,1"
      ];
      description = ''
        hyprland monitor layouts
      '';
    };

    hyprlandWallpaper = lib.mkOption {
      default = "~/Pictures/Wallpapers/evening-sky.png";
      description = ''
	path to wallpaper
      '';
    };
  };
  config = {
    imports = [
     ./hyprland.nix
     ./mako.nix
     ./rofi.nix
     ./waybar.nix
    ];

    hyprlandMonitors = config.hyprlandMonitors;
    hyprlandWallpaper = config.hyprlandWallpaper;

    home.packages = with pkgs; [ 
      # Wallpaper
      swww

      # Screenshots
      grim
      slurp
      wl-clipboard
    ];
  };
}
