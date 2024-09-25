{pkgs, ...}:
{
   wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;
    settings = {
	# Variables
	"$mod" = "SUPER";
	"$terminal" = "kitty";
	"$fileManager" = "dolphin";
	"$menu" = "wofi --show drun";

	# ENV
	env = [
	  "XCURSOR_SIZE,24"
	  "HYPRCURSOR_SIZE,24"
	];

	general = {
	  gaps_in = 5;
	  gaps_out = 20;

	  border_size = 2;
	  
	  col.active_border = "rgba(33ccffee) rgba(00ff99ee) 45deg";
	  col.inactive_border = "rgba(595959aa)";

	  resize_on_border = false;
	  allow_tearing = false;
	  layout = "dwindle";
	};

	decoration = {
	  rouding = 10;

	  active_opacity = 1.0;
	  inactive_opacity = 1.0;

	  drop_shadow = true;
	  shadow_range = 4;
	  shadow_render_power = 3;
	  col.shadow = "rgba(1a1a1aee)";

	  blur = {
	    enabled = true;
	    size = 3;
	    passes = 1;
	    vibrancy = 0.1696;
	  };
	};

	dwindle = {
	  pseudotile = true; 
	  preserve_split = true;
	};

	master = {
	  new_status = "master";
	};

	input = {
	  kb_layout = "us";
	  follow_mouse = 1;
	  touchpad = {
	    natural_scroll = false;
	  };
	};

	# Keybinds
	bind = [
	  # Launch Programs
	  "$mod, F, exec, firefox"
	  "$mod, Q, exec, $terminal"

	  # Change window focus
	  "$mod, left, movefocus, l"
	  "$mod, right, movefocus, r"
	  "$mod, up, movefocus, u"
	  "$mod, down, movefocus, d"

	  # Scroll workspaces
	  "$mod, mouse_down, workspace, e+1"
	  "$mod, mouse_up, workspace, e-1"

	  # Mouse Move Windows
	  "$mod, mouse:272, movewindow"
	  "$mod, mouse:273, resizewindow"
	] ++ (
	  builtins.concatLists (builtins.genList (i:
            let ws = i + 1;
            in [
              "$mod, code:1${toString i}, workspace, ${toString ws}"
              "$mod SHIFT, code:1${toString i}, movetoworkspace, ${toString ws}"
            ]
          )
          9)
	);

	windowrulev2 = "suppressevent maximize, class:.*";
	monitor = ",preferred,auto,auto";
    };
  };

  
  home.packages = with pkgs; [ 
    waybar

    mako 
    libnotify
  
    wofi
  ];
}
