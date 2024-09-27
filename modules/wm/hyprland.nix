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
  "$menu" = "rofi -show drun -show-icons";

  "exec-once" = [
    "swww-daemon"
    "swww img ~/Pictures/Wallpapers/eepy-kebin.jpg"
    "waybar"
    "mako"
  ];

  # ENV
  env = [
    "XCURSOR_SIZE,24"
    "HYPRCURSOR_SIZE,24"
  ];

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

  windowrulev2 = [
    "workspace special, initialTitle:^(Spotify)(.*)$"
  ];

  workspace = [
    "name:dev,monitor:DP-2,default:true,on-created-empty:kitty"

    "name:content,monitor:DP-1,default:true,on-created-empty:discord"
    "name:stream,monitor:DP-1,on-created-empty:obs"
  ];

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

    "$mod, TAB, togglespecialworkspace"

    "$mod, D, workspace, name:dev"
    "$mod, F, workspace, name:content"
    "$mod SHIFT, S, workspace, name:stream"
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

  bindm = [ 
    # Mouse Move Windows
    "$mod, mouse:272, movewindow"
    "$mod, mouse:273, resizewindow"
  ];

  monitor = [
    "DP-2,preferred,0x0,1"
    "DP-1,preferred,-1440x-480,1,transform,1"
  ];
    };
  };

  programs.waybar = {
    enable = true;
    settings = {
      mainBar = {
         layer = "top";
         position = "top";
         spacing = 4;
         output = [
            "DP-1"
            "DP-2"
         ];

         modules-left = [
            "hyprland/workspaces"
         ];

         modules-center = [
            "hyprland/window"
         ];

         modules-right = [
            "pulseaudio"
            "cpu"
            "memory"
            "clock"
         ];

         "hyprland/workspaces" = {
            disable-scroll = true;
            all-outputs = true;
         };
  
         "clock" = {
            tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
            format-alt = "{:%Y-%m-%d}";
         };

         "cpu" = {
            format = "{usage}% ";
         };

         "memory" = {
            format = "{}% ";
         };
      };
    };

    style = ''
      * {
          border: none;
          border-radius: 0;
          font-family: "Ubuntu Nerd Font";
          font-size: 13px;
          min-height: 0;
      }

      window#waybar {
          background: rgba(0,0,0,0.5);
          color: white;
      }

      #window {
          font-weight: bold;
          font-family: "Ubuntu";
      }
      /*
      #workspaces {
          padding: 0 5px;
      }
      */

      #workspaces button {
          padding: 0 5px;
          background: transparent;
          color: white;
          border-top: 2px solid transparent;
      }

      #workspaces button.focused {
          color: #c9545d;
          border-top: 2px solid #c9545d;
      }

      #mode {
          background: #64727D;
          border-bottom: 3px solid white;
      }

      #clock, #battery, #cpu, #memory, #network, #pulseaudio, #custom-spotify, #tray, #mode {
          padding: 0 3px;
          margin: 0 2px;
      }

      #clock {
          font-weight: bold;
      }

      #battery {
      }

      #battery icon {
          color: red;
      }

      #battery.charging {
      }

      @keyframes blink {
          to {
              background-color: #ffffff;
              color: black;
          }
      }

      #battery.warning:not(.charging) {
          color: white;
          animation-name: blink;
          animation-duration: 0.5s;
          animation-timing-function: linear;
          animation-iteration-count: infinite;
          animation-direction: alternate;
      }

      #cpu {
      }

      #memory {
      }

      #network {
      }

      #network.disconnected {
          background: #f53c3c;
      }

      #pulseaudio {
      }

      #pulseaudio.muted {
      }

      #custom-spotify {
          color: rgb(102, 220, 105);
      }

      #tray {
      } 
    '';
  };

  services.mako = {
   enable = true; 
   defaultTimeout = 2000;
   backgroundColor = "#1E1E2E";
   textColor = "#CDD6F4";
   borderColor = "#89B4FA";
  };

  programs.rofi = {
   enable = true;
   package = pkgs.rofi-wayland;
   theme = "catppuccin-mocha"; 
  };

  home.file.".local/share/rofi/themes/catppuccin-mocha.rasi".source = ./catppuccin-mocha.rasi;
  
  home.packages = with pkgs; [ 
    # Status Bar
    waybar
    font-awesome

    # Notifications
    mako 
    libnotify
  
    # App launcher
    rofi-wayland

    # Wallpaper
    swww

    # Screenshots
    grim
    slurp
    wl-clipboard
  ];
}
