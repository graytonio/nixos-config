{ inputs, ...}:
{
  imports = [ inputs.hyprpanel.homeManagerModules.hyprpanel ];  

  programs.hyprpanel = {
    enable = true;
    overlay.enable = true;
    overwrite.enable = true;
    theme = "catppuccin_mocha";

    layout = {
      "bar.layouts" = {
        "0" = {
          left = [
	    "dashboard"
	  ];

	  middle = [
	    "media"
	  ];

	  right = [
	    "volume"
	    "systray"
	    "clock"
	    "notifications"
	  ];
	};

	"1" = {
	  left = [
	    "dashboard"
	  ];

	  middle = [
	    "media"
	  ];

	  right = [
	    "clock"
	  ];
	};
      };
    };

    settings = {
      theme.bar.transparent = true;
      theme.bar.layer = "bottom";
    };
  };
}
