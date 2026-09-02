{pkgs, ...}: {
  programs.swaylock = {
    enable = true;
    package = pkgs.swaylock-effects;
    settings = {
      ignore-empty-password = true;
      show-failed-attempts = true;

      indicator-idle-visible = true;
      clock = true;

      timestr = "%H:%M";
      datestr = "%a %F";

      image = "/home/philipp/Pictures/wallpaper.jpg";
      scaling = "fill";

      inside-color = "#303446";
      inside-clear-color = "#303446";
      inside-ver-color = "#303446";
      inside-wrong-color = "#303446";

      ring-color = "#51576d";
      ring-clear-color = "#8caaee";
      ring-ver-color = "#a6d189";
      ring-wrong-color = "#e78284";

      text-color = "#c6d0f5";
      text-clear-color = "#c6d0f5";
      text-ver-color = "#c6d0f5";
      text-wrong-color = "#c6d0f5";

      key-hl-color = "#f4b8e4";
      bs-hl-color = "#e78284";

      line-color = "#303446";
      line-clear-color = "#303446";
      line-ver-color = "#303446";
      line-wrong-color = "#303446";

      separator-color = "#51576d";

      font = "Inconsolata Nerd Font";
      font-size = 80;

      indicator-radius = 120;
      indicator-thickness = 10;
    };
  };
}
