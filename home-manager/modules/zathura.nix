{...}: {
  programs.zathura = {
    enable = true;
    options = {
      font = "Inconsolata LGC Nerd Font 11";
      selection-clipboard = "clipboard";
      scroll-step = 50;

      # Catppuccin Frappe
      default-bg = "#303446";
      default-fg = "#c6d0f5";
      statusbar-bg = "#51576d";
      statusbar-fg = "#c6d0f5";
      inputbar-bg = "#303446";
      inputbar-fg = "#c6d0f5";
      notification-bg = "#303446";
      notification-fg = "#c6d0f5";
      notification-error-bg = "#303446";
      notification-error-fg = "#e78284";
      notification-warning-bg = "#303446";
      notification-warning-fg = "#e5c890";
      completion-bg = "#51576d";
      completion-fg = "#c6d0f5";
      completion-highlight-bg = "#ca9ee6";
      completion-highlight-fg = "#303446";
      highlight-color = "rgba(229,200,144,0.5)";
      highlight-active-color = "rgba(202,158,230,0.5)";
    };
  };
}
