{lib, config, ...}:
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

    hyprlandWorkspaces = lib.mkOption {
      default = [];
      description = ''
	hyprland workspace rules
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
	"$browser" = "firefox";
        "$menu" = "rofi -show drun -show-icons";

	# Startup Daemons
        "exec-once" = [
          "swww-daemon"
          "swww img ${config.hyprlandWallpaper}"
          "mako"

	  "eww daemon"
	  "eww open bar"
        ];

        xwayland = {
	  force_zero_scaling = true;
	};

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
	  "workspace special:discord, class:^(discord)$"
	  "monitor DP-2, class:^(Waydroid)$"
	  "workspace name:stream, class:^(com.obsproject.Studio)$"
	];

	monitor = config.hyprlandMonitors;

	workspace = 
 	let	
	  monitor1 = builtins.elemAt (lib.strings.splitString "," (builtins.elemAt config.hyprlandMonitors 0)) 0;
	  monitor2 = builtins.elemAt (lib.strings.splitString "," (builtins.elemAt config.hyprlandMonitors 1)) 0;
	in 
	[
	  "name:dev${if builtins.length config.hyprlandMonitors > 1 then ",monitor:${monitor1}" else ""},default:true,on-created-empty:$terminal"
	  "name:game${if builtins.length config.hyprlandMonitors > 1 then ",monitor:${monitor1}" else ""},border:false,rounding:false,on-created-empty:steam"
	  "name:browser${if builtins.length config.hyprlandMonitors > 1 then ",monitor:${monitor1}" else ""},on-created-empty:$browser"
	  "name:content${if builtins.length config.hyprlandMonitors > 1 then ",monitor:${monitor2},default:true" else ""},on-created-empty:$browser --new-window \"https://youtube.com\""
	  "name:stream${if builtins.length config.hyprlandMonitors > 1 then ",monitor:${monitor2}" else ""}"
	];

	input = {
	  kb_layout = "us";
	  follow_mouse = 1;
	  touchpad = {
	    natural_scroll = true;
	  };
	};

	# Keybindings
	bind = [
	  # System
          "$mod, M, exit"
          "$mod, C, killactive"
          "$mod, V, togglefloating"
	  "$mod, Home, exec, fish -c 'grim -l 0 -g (slurp) - | wl-copy'"

          # Launch Programs
          "$mod, R, exec, $menu"
          "$mod, E, exec, $browser"
          "$mod, Q, exec, $terminal"

          # Change window focus
          "$mod, left, movefocus, l"
          "$mod, right, movefocus, r"
          "$mod, up, movefocus, u"
          "$mod, down, movefocus, d"

          # Scroll workspaces
          "$mod, mouse_down, workspace, e+1"
          "$mod, mouse_up, workspace, e-1"

	  # "Minimize" Window
	  "$mod, TAB, togglespecialworkspace, magic"
	  "$mod, TAB, movetoworkspace, +0"
	  "$mod, TAB, togglespecialworkspace, magic"
	  "$mod, TAB, movetoworkspace, special:magic"
	  "$mod, TAB, togglespecialworkspace, magic"

	  # Special Workspaces
	  "$mod, Z, togglespecialworkspace, spotify"
	  "$mod, X, togglespecialworkspace, discord"

	  # Named Workspaces
	  "$mod, A, workspace, name:dev"
	  "$mod SHIFT, A, movetoworkspace, name:dev"

	  "$mod, S, workspace, name:game"
	  "$mod SHIFT, S, movetoworkspace, name:game"

	  "$mod, D, workspace, name:browser"
	  "$mod SHIFT, D, movetoworkspace, name:browser"

	  "$mod, F, workspace, name:content"
	  "$mod SHIFT, F, movetoworkspace, name:content"
	  
	  "$mod, G, workspace, name:stream"
	  "$mod SHIFT, G, movetoworkspace, name:stream"
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
