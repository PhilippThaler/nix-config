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
        {command = "kitty --class siggy siggy";}
        {command = "kitty --class neomutt neomutt";}
        {command = "sh -c 'sleep 2; swaymsg [workspace=4] layout stacking'";}
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

      keybindings = lib.mkOptionDefault (import ./keybindings.nix {inherit modifier term;});

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
