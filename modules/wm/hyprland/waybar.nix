{pkgs, lib, config, ...}:
{
  programs.waybar = {
    enable = true;
    settings = {
      mainBar = {
	layer = "top";
	position = "top";
	spacing = 4;	
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

        "pulseaudio" = {
          on-click = "pavucontrol";
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

  home.packages = with pkgs; [
    font-awesome
  ];
}


