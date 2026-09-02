{config, ...}: let
  inherit (config.lib.formats.rasi) mkLiteral;
in {
  programs.rofi = {
    enable = true;
    font = "Inconsolata Nerd Font 13";
    theme = {
      "*" = {
        background = mkLiteral "#303446";
        foreground = mkLiteral "#c6d0f5";

        lightbg = mkLiteral "#303446";
        lightfg = mkLiteral "#c6d0f5";
        normal-background = mkLiteral "#303446";
        normal-foreground = mkLiteral "#c6d0f5";
        alternate-normal-background = mkLiteral "#303446";
        alternate-normal-foreground = mkLiteral "#c6d0f5";
        selected-normal-background = mkLiteral "#f4b8e4";
        selected-normal-foreground = mkLiteral "#303446";
        active-background = mkLiteral "#303446";
        active-foreground = mkLiteral "#f4b8e4";
        urgent-background = mkLiteral "#e78284";
        urgent-foreground = mkLiteral "#c6d0f5";

        background-color = mkLiteral "#303446";
        text-color = mkLiteral "#c6d0f5";
        border-color = mkLiteral "#51576d";
      };

      "window" = {
        background-color = mkLiteral "#303446";
        border = mkLiteral "2";
        border-color = mkLiteral "#51576d";
        border-radius = mkLiteral "8";
        padding = mkLiteral "12";
      };

      "entry" = {
        background-color = mkLiteral "#414559";
        text-color = mkLiteral "#c6d0f5";
        cursor-color = mkLiteral "#f4b8e4";
        placeholder-color = mkLiteral "#838ba7";
        placeholder = "Search...";
        padding = mkLiteral "8 12";
        border-radius = mkLiteral "6";
      };

      "listview" = {
        background-color = mkLiteral "transparent";
        padding = mkLiteral "4 0";
        lines = mkLiteral "8";
        dynamic = mkLiteral "true";
      };

      "element" = {
        padding = mkLiteral "6 12";
        border-radius = mkLiteral "4";
      };

      "element-text" = {
        background-color = mkLiteral "inherit";
        text-color = mkLiteral "inherit";
      };

      "element-icon" = {
        background-color = mkLiteral "inherit";
      };

      "element.selected" = {
        background-color = mkLiteral "#f4b8e4";
        text-color = mkLiteral "#303446";
      };

      "element.urgent" = {
        background-color = mkLiteral "#e78284";
        text-color = mkLiteral "#c6d0f5";
      };

      "element.active" = {
        background-color = mkLiteral "#414559";
        text-color = mkLiteral "#f4b8e4";
      };
    };
  };
}
