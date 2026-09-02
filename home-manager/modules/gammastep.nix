{...}: {
  services.gammastep = {
    enable = true;
    latitude = 48.21;
    longitude = 16.37;
    temperature.day = 5000;
    temperature.night = 3200;
    settings.general.fade = 1;
  };
}
