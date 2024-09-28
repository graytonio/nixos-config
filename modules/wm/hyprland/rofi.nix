{pkgs, config, lib}:
{
  programs.rofi = {
    enable = true;
    package = pkgs.rofi-wayland;
    theme = "catppuccin-mocha"; 
  };

  home.file.".local/share/rofi/themes/catppuccin-mocha.rasi".source = ./catppuccin-mocha.rasi;
}

