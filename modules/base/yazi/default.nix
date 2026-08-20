{pkgs, ...}:
{
  programs.yazi = {
    enable = true;
    enableFishIntegration = true;
    shellWrapperName = "yy";
    settings = {
      opener = {
        session = [
          { 
            run = "tmux-session $0";
	    orphan = true;
	  }
	];
      };

      open = {
        prepend_rules = [
          {
            name = "*/";
	    use = "session";
	  }
	];
      };
    };
  };
}
