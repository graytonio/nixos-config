{ ... }: {
  programs.kitty = {
    enable = true;
    theme = "Dracula";
    settings = {
	dynamic_background_opacity = true;	
    };
  };
}

