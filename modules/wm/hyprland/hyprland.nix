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
    wayland.windowManager.hyprland = {
      enable = true;
      xwayland.enable = true;
      settings = {
	# Variables
        "$mod" = "SUPER";
        "$terminal" = "kitty";
        "$fileManager" = "dolphin";
        "$menu" = "rofi -show drun -show-icons";

	# Startup Daemons
        "exec-once" = [
          "swww-daemon"
          "swww img ${config.hyprlandWallpaper}"
          "waybar"
          "mako"
        ];

	# ENV Settings
	env = [
          "XCURSOR_SIZE,24"
          "HYPRCURSOR_SIZE,24"
        ];

	# Basic Spacing and Layout
        general = {
          gaps_in = 5;
          gaps_out = 20;

          border_size = 2;
          
          "col.active_border" = "rgba(33ccffee) rgba(00ff99ee) 45deg";
          "col.inactive_border" = "rgba(595959aa)";

          resize_on_border = false;
          allow_tearing = false;
          layout = "dwindle";
        };

	# Window Decoration Settings
        decoration = {
          rounding = 10;

          active_opacity = 1.0;
          inactive_opacity = 1.0;

          drop_shadow = true;
          shadow_range = 4;
          shadow_render_power = 3;
          "col.shadow" = "rgba(1a1a1aee)";

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

	windowrulev2 = [
	  "workspace special:spotify, initialTitle:^(Spotify)(.*)$"
	  "opacity 0.8, focus:0"
	];

	monitors = config.hyprlandMonitors;

	workspace = (if builtins.length config.hyprlandMonitors == 1 then
	  [
	    "name:dev,default:true,on-created-empty:kitty"
	    "name:game,on-created-empty:steam"
	    "name:content,on-created-empty:discord"
	  ]
	else if builtins.length config.hyprlandMonitors == 2 then
	  let 
	    monitor1 = builtins.elemAt (lib.strings.splitString (builtins.elemAt config.hyprlandMonitors 0)) 0;
	    monitor2 = builtins.elemAt (lib.strings.splitString (builtins.elemAt config.hyprlandMonitors 1)) 0;
	  in [
            "name:dev,monitor:${monitor1},default:true,on-created-empty:kitty"
	    "name:game,monitor:${monitor1},on-created-empty:steam"
	    
	    "name:content,monitor:${monitor2},default:true,on-created-empty:discord"
	    "name:stream,monitor:${monitor2},on-created-empty:obs"
	  ]
	else []
	);

	input = {
	  kb_layout = "us";
	  follow_mouse = 1;
	  touchpad = {
	    natural_scroll = false;
	  };
	};

	# Keybindings
	bind = [
	  # System
          "$mod, M, exit"
          "$mod, C, killactive"
          "$mod, V, togglefloating"

          # Launch Programs
          "$mod, R, exec, $menu"
          "$mod, E, exec, firefox"
          "$mod, Q, exec, $terminal"

          # Change window focus
          "$mod, left, movefocus, l"
          "$mod, right, movefocus, r"
          "$mod, up, movefocus, u"
          "$mod, down, movefocus, d"

          # Scroll workspaces
          "$mod, mouse_down, workspace, e+1"
          "$mod, mouse_up, workspace, e-1"

	  # Named Workspaces
	  "$mod, S, togglespecialworkspace spotify"
	  "$mod, D, workspace, name:dev"
	  "$mod, F, workspace, name:content"
	  "$mod, G, workspace, name:game"
	  "$mod SHIFT, S, workspace, name:stream"
	] ++ (
	  builtins.concatLists (builtins.genList(i:
	    let ws = i + 1;
	    in [
	      "$mod, code:1${toString i}, workspace, ${toString ws}"
	      "$mod SHIFT, code:1${toString i}, movetoworkspace, ${toString ws}"
	    ]
	  ) 9)
	);

	# Mouse bindings
	bindm = [
	  "$mod, mouse:272, movewindow"
	  "$mod, mouse:273, resizewindow"
	];
      };
    };
  };
}
