{ ... }: {
  programs.kitty = {
    enable = true;
    theme = "Catppuccin-Mocha";
    settings = {
      dynamic_background_opacity = true;	
    };
  };
}
