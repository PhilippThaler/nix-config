{pkgs, ...}: let
  siggy = pkgs.callPackage ../../pkgs/siggy {};
in {
  xdg.desktopEntries.siggy = {
    name = "Siggy";
    genericName = "Signal Messenger";
    comment = "Terminal-based Signal client";
    exec = "kitty --class siggy ${siggy}/bin/siggy";
    terminal = false;
    icon = "signal";
    categories = ["Network" "InstantMessaging"];
  };
}
