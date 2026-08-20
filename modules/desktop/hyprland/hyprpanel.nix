{ inputs, pkgs, ... }:
{
  programs.hyprpanel = {
    enable = true;
    package = inputs.hyprpanel.packages.${pkgs.stdenv.hostPlatform.system}.default;

    settings.layout = {
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
      theme.name = "catppuccin_mocha";
      theme.bar.transparent = true;
      theme.bar.layer = "bottom";
    };
  };
}
