{
  pkgs,
  lib,
  ...
}: {
  wayland.windowManager.sway = {
    enable = true;
    package = pkgs.swayfx;
    checkConfig = false;

    wrapperFeatures.gtk = true;

    config = let
      modifier = "Mod4";
      term = "kitty";
    in {
      inherit modifier;
      terminal = term;
      menu = "rofi";

      # waybar is our bar; HM injects a default i3bar/i3status otherwise
      bars = [];

      input = {
        "type:keyboard" = {
          xkb_layout = "de";
          xkb_variant = "deadgraveacute";
          xkb_options = "caps:swapescape";
        };
        "type:touchpad" = {
          tap = "enabled";
          drag_lock = "disabled";
          scroll_factor = "1.0";
        };
      };

      seat = {
        "*" = {
          xcursor_theme = "capitaine-cursors 36";
        };
      };

      output = {
        "*" = {
          bg = "/home/philipp/Pictures/wallpaper.jpg fill";
        };
        "eDP-1" = {
          scale = "1.5";
        };
      };

      fonts = {
        names = ["Inconsolata Nerd Font"];
        size = 11.0;
      };

      window = {
        titlebar = false;
        border = 0;
        hideEdgeBorders = "none";
      };
      floating = {
        modifier = "Mod4";
        border = 2;
      };

      gaps = {
        inner = 30;
        outer = 10;
        smartGaps = "on";
        smartBorders = "on";
      };

      focus = {
        followMouse = false;
      };

      workspaceAutoBackAndForth = true;

      startup = [
        {command = "${pkgs.mate-polkit}/libexec/polkit-mate-authentication-agent-1";}
        {command = "nm-applet";}
        {command = "nextcloud";}
        {command = "kdeconnectd";}
        {command = "sh -c 'sleep 2 && kdeconnect-indicator'";}
        {command = "swaync";}
        {command = "gammastep -m wayland -c $HOME/.config/gammastep/config.ini";}
        {command = "kitty --class siggy siggy";}
        {command = "kitty --class neomutt neomutt";}
        {command = "sh -c 'sleep 2; swaymsg [workspace=4] layout stacking'";}
        {command = "autotiling -l 2";}
        {
          command = "sh -c 'pkill -f \"bash /home/philipp/bin/[b]attery-warn\"; exec /home/philipp/bin/battery-warn'";
          always = true;
        }
        {
          command = "sh -c 'pkill swayidle; exec /home/philipp/bin/swayidle-daemon'";
          always = true;
        }
        {
          command = "sh -c 'pkill waybar; waybar'";
          always = true;
        }
      ];

      assigns = {
        "4" = [
          {app_id = "siggy";}
          {app_id = "neomutt";}
        ];
        "5" = [
          {app_id = "spotify";}
          {class = "Spotify";}
        ];
      };

      window.commands = [
        {
          command = "floating enable, border pixel 1";
          criteria = {title = "alsamixer";};
        }
        {
          command = "floating enable, border pixel 0";
          criteria = {app_id = "mpv";};
        }
        {
          command = "floating enable";
          criteria = {title = "File Transfer*";};
        }
        {
          command = "floating enable, border pixel 1";
          criteria = {app_id = "(?i)galculator";};
        }
        {
          command = "floating enable, border normal";
          criteria = {class = "GParted";};
        }
        {
          command = "floating enable, border none";
          criteria = {title = "rofi-cheatsheet-helper";};
        }
        {
          command = "floating enable";
          criteria = {app_id = "(?i)pavucontrol";};
        }
        {
          command = "floating enable, border normal";
          criteria = {app_id = "(?i)SimpleScan";};
        }
        {
          command = "floating enable, resize set 1000 600, move position center";
          criteria = {app_id = "delve-terminal";};
        }
        {
          command = "floating enable, border normal";
          criteria = {app_id = "(?i)system-config-printer";};
        }
        {
          command = "focus";
          criteria = {urgent = "latest";};
        }
      ];

      keybindings = lib.mkOptionDefault {
        # Launchers
        "${modifier}+Return" = "exec ${term}";
        "${modifier}+d" = "exec rofi -show drun";
        "${modifier}+Shift+d" = "exec --no-startup-id rofimoji";
        "${modifier}+Shift+s" = "exec --no-startup-id rofi -show window";
        "${modifier}+c" = "exec --no-startup-id rofi-cheatsheet-helper";
        "${modifier}+Shift+x" = "exec --no-startup-id $HOME/bin/force-kill";

        # Lock
        "${modifier}+Mod1+l" = "exec swaylock -f";

        # Notifications
        "${modifier}+n" = "exec --no-startup-id swaync-client -t";

        # Apps
        "${modifier}+F3" = "exec kitty ranger";
        "${modifier}+Ctrl+F3" = "exec pcmanfm";
        "${modifier}+Shift+F3" = "exec pkexec pcmanfm";

        # Screenshots & recording
        "Print" = "exec --no-startup-id $HOME/bin/screenshot-full";
        "${modifier}+Print" = "exec --no-startup-id $HOME/bin/screenshot-window-clip";
        "${modifier}+Ctrl+Print" = "exec --no-startup-id $HOME/bin/screenshot-region";
        "${modifier}+Shift+Print" = "exec --no-startup-id $HOME/bin/screenshot-region-clip";
        "${modifier}+Shift+v" = "exec --no-startup-id $HOME/bin/record-screen";
        "${modifier}+Ctrl+v" = "exec --no-startup-id $HOME/bin/record-screen region";
        "${modifier}+Shift+i" = "exec $HOME/bin/sway-wininfo";
        "${modifier}+Shift+p" = "exec wdisplays";

        # Volume
        "XF86AudioRaiseVolume" = "exec --no-startup-id $HOME/bin/change-volume 5%+ unmute";
        "XF86AudioLowerVolume" = "exec --no-startup-id $HOME/bin/change-volume 5%- unmute";
        "XF86AudioMute" = "exec --no-startup-id $HOME/bin/change-volume toggle-mute";

        # Brightness
        "XF86MonBrightnessUp" = "exec --no-startup-id brightnessctl set 20%+";
        "XF86MonBrightnessDown" = "exec --no-startup-id brightnessctl set 20%-";

        # Move window with script
        "${modifier}+Shift+h" = "exec --no-startup-id $HOME/bin/move-window left";
        "${modifier}+Shift+j" = "exec --no-startup-id $HOME/bin/move-window down";
        "${modifier}+Shift+k" = "exec --no-startup-id $HOME/bin/move-window up";
        "${modifier}+Shift+l" = "exec --no-startup-id $HOME/bin/move-window right";

        # Workspaces back & forth / nav
        "${modifier}+b" = "workspace back_and_forth";
        "${modifier}+Tab" = "workspace next";
        "${modifier}+Shift+Tab" = "workspace prev";
        "${modifier}+Shift+b" = "move container to workspace back_and_forth; workspace back_and_forth";
        "${modifier}+Ctrl+Right" = "workspace next";
        "${modifier}+Ctrl+Left" = "workspace prev";

        # Split / layout
        "${modifier}+q" = "split toggle";
        "${modifier}+f" = "fullscreen toggle";
        "${modifier}+s" = "layout stacking";
        "${modifier}+w" = "layout tabbed";
        "${modifier}+e" = "layout toggle split";
        "${modifier}+Shift+space" = "floating toggle";
        "${modifier}+space" = "focus mode_toggle";
        "${modifier}+a" = "focus parent";

        # Workspaces
        "${modifier}+1" = "workspace number 1";
        "${modifier}+2" = "workspace number 2";
        "${modifier}+3" = "workspace number 3";
        "${modifier}+4" = "workspace number 4";
        "${modifier}+5" = "workspace number 5";
        "${modifier}+6" = "workspace number 6";
        "${modifier}+7" = "workspace number 7";
        "${modifier}+8" = "workspace number 8";
        "${modifier}+9" = "workspace number 9";

        "${modifier}+Ctrl+1" = "move container to workspace number 1";
        "${modifier}+Ctrl+2" = "move container to workspace number 2";
        "${modifier}+Ctrl+3" = "move container to workspace number 3";
        "${modifier}+Ctrl+4" = "move container to workspace number 4";
        "${modifier}+Ctrl+5" = "move container to workspace number 5";
        "${modifier}+Ctrl+6" = "move container to workspace number 6";
        "${modifier}+Ctrl+7" = "move container to workspace number 7";
        "${modifier}+Ctrl+8" = "move container to workspace number 8";
        "${modifier}+Ctrl+9" = "move container to workspace number 9";

        "${modifier}+Shift+1" = "move container to workspace number 1; workspace number 1";
        "${modifier}+Shift+2" = "move container to workspace number 2; workspace number 2";
        "${modifier}+Shift+3" = "move container to workspace number 3; workspace number 3";
        "${modifier}+Shift+4" = "move container to workspace number 4; workspace number 4";
        "${modifier}+Shift+5" = "move container to workspace number 5; workspace number 5";
        "${modifier}+Shift+6" = "move container to workspace number 6; workspace number 6";
        "${modifier}+Shift+7" = "move container to workspace number 7; workspace number 7";
        "${modifier}+Shift+8" = "move container to workspace number 8; workspace number 8";
        "${modifier}+Shift+9" = "move container to workspace number 9; workspace number 9";

        # Scratchpad
        "${modifier}+minus" = "exec --no-startup-id $HOME/bin/toggle_scratchpad";

        # Power menu
        "${modifier}+0" = "exec --no-startup-id $HOME/bin/powermenu";

        # Reload
        "${modifier}+Shift+r" = "reload";

        # Resize mode
        "${modifier}+r" = "mode resize";
      };

      modes = {
        resize = {
          h = "resize shrink width 5 px or 5 ppt";
          j = "resize grow height 5 px or 5 ppt";
          k = "resize shrink height 5 px or 5 ppt";
          l = "resize grow width 5 px or 5 ppt";
          Return = "mode default";
          Escape = "mode default";
        };
      };
    };

    extraConfig = ''
      set $mod Mod4
      floating_minimum_size 75 x 50
      floating_maximum_size 1200 x 600
      set $mode_gaps Gaps: (o) outer, (i) inner
      set $mode_gaps_outer Outer Gaps: +|-|0 (local), Shift + +|-|0 (global)
      set $mode_gaps_inner Inner Gaps: +|-|0 (local), Shift + +|-|0 (global)
      bindsym $mod+Shift+g mode "$mode_gaps"

      mode "$mode_gaps" {
          bindsym o      mode "$mode_gaps_outer"
          bindsym i      mode "$mode_gaps_inner"
          bindsym Return mode "default"
          bindsym Escape mode "default"
      }
      mode "$mode_gaps_inner" {
          bindsym plus  gaps inner current plus 5
          bindsym minus gaps inner current minus 5
          bindsym 0     gaps inner current set 0

          bindsym Shift+plus  gaps inner all plus 5
          bindsym Shift+minus gaps inner all minus 5
          bindsym Shift+0     gaps inner all set 0

          bindsym Return mode "default"
          bindsym Escape mode "default"
      }
      mode "$mode_gaps_outer" {
          bindsym plus  gaps outer current plus 5
          bindsym minus gaps outer current minus 5
          bindsym 0     gaps outer current set 0

          bindsym Shift+plus  gaps outer all plus 5
          bindsym Shift+minus gaps outer all minus 5
          bindsym Shift+0     gaps outer all set 0

          bindsym Return mode "default"
          bindsym Escape mode "default"
      }

      # SwayFX eye candy
      corner_radius 8
      shadows enable
      shadows_on_csd enable
      blur enable
      blur_xray enable
      layer_effects "waybar" blur enable

      # Scratchpad dropdown terminal
      for_window [title="scratchpad_dropdown"] floating enable, resize set 1200 1000, move position center, move scratchpad

      include /etc/sway/config.d/*
    '';
  };
}
