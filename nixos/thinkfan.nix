{ config, pkgs, lib, ... }:
{
  # ── ThinkPad fan control (thinkfan) ──────────────────────────────
  # Requires thinkpad_acpi with fan_control=1 (set via modprobe option below).

  environment.systemPackages = [ pkgs.thinkfan ];

  environment.etc."thinkfan.yaml".source = ./thinkfan.yaml;

  # thinkpad_acpi must allow raw fan control; loaded as module on this kernel
  boot.extraModprobeConfig = "options thinkpad_acpi fan_control=1";

  systemd.services.thinkfan = {
    description = "ThinkPad fan control daemon (thinkfan)";
    wantedBy = [ "multi-user.target" ];
    after = [ "systemd-modules-load.service" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.thinkfan}/bin/thinkfan -n -c /etc/thinkfan.yaml";
      Restart = "on-failure";
      RestartSec = 5;
    };
  };
}
