{...}: {
  # Weekly LVFS check; fwupd-check script notifies via swaync (needs polkit rule for refresh-remote)
  systemd.user.services.fwupd-check = {
    Unit = {
      Description = "Check LVFS for firmware updates";
      After = ["network-online.target"];
      Wants = ["network-online.target"];
    };
    Service = {
      Type = "oneshot";
      ExecStart = "%h/bin/fwupd-check";
    };
  };

  systemd.user.timers.fwupd-check = {
    Unit = {
      Description = "Weekly firmware update check";
    };
    Timer = {
      OnCalendar = "Mon *-*-* 09:30";
      RandomizedDelaySec = "30m";
      Persistent = true;
    };
    Install.WantedBy = ["timers.target"];
  };
}