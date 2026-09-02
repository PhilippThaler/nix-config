{
  modifier,
  term,
  ...
}: {
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
}
