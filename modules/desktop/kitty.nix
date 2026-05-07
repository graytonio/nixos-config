{ ... }: {
  programs.kitty = {
    enable = true;
    themeFile = "Catppuccin-Mocha";
    settings = {
      dynamic_background_opacity = true;	
    };
  };
}
