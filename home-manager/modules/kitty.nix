{...}: {
  programs.kitty = {
    enable = true;

    themeFile = "Catppuccin-Frappe";

    settings = {
      font_family = "Inconsolata LGC Nerd Font Mono";
      bold_font = "Inconsolata LGC Nerd Font Mono Bold";
      italic_font = "Inconsolata LGC Nerd Font Mono Italic";
      bold_italic_font = "Inconsolata LGC Nerd Font Mono Bold Italic";
      font_size = 14.0;

      adjust_line_height = "100%";
      adjust_column_width = 0;

      # Allow remote programs (neovim over SSH via OSC 52) to read the clipboard
      clipboard_control = "read-clipboard write-clipboard";
      copy_on_select = true;

      tab_bar_align = "end";
      tab_bar_show_new_tab_button = true;
      tab_bar_min_tabs = 2;
      notify_on_cmd_finish = "never";

      wheel_scroll_multiplier = 8.0;
      touch_scroll_multiplier = 8.0;

      strip_trailing_spaces = "smart";
      input_delay = 1;

      enable_audio_bell = false;
      background_opacity = 0.85;
    };

    keybindings = {
      "cmd+shift+c" = "copy_to_clipboard";
      "cmd+shift+v" = "paste_from_clipboard";
    };
  };
}
