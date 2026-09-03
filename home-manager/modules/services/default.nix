{pkgs, ...}: {
  services.autotiling = {
    enable = true;
    extraArgs = [
      "-l"
      "2"
    ];
  };

  services.batsignal.enable = true;

  services.gammastep = {
    enable = true;
    latitude = 48.21;
    longitude = 16.37;
    temperature.day = 5000;
    temperature.night = 3200;
    settings.general.fade = 1;
  };

  services.gnome-keyring = {
    enable = true;
    components = ["secrets"];
  };

  services.kdeconnect = {
    enable = true;
    indicator = true;
  };

  services.network-manager-applet.enable = true;
  services.nextcloud-client = {
    enable = true;
    startInBackground = true;
  };

  services.polkit-gnome.enable = true;

  services.swaync.enable = true;

  services.swayidle = {
    enable = true;
    timeouts = [
      {
        timeout = 600;
        command = "${pkgs.brightnessctl}/bin/brightnessctl -s set 10%";
        resumeCommand = "${pkgs.brightnessctl}/bin/brightnessctl -r";
      }
      {
        timeout = 610;
        command = "${pkgs.swaylock}/bin/swaylock -fF";
      }
      {
        timeout = 1510;
        command = "${pkgs.systemd}/bin/systemctl suspend";
      }
    ];
  };

  services.tldr-update.enable = true;
}
