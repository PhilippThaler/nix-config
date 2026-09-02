{pkgs, ...}: {
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
}
