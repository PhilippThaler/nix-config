{lib, ...}: {
  programs.waybar = {
    enable = true;
    settings = { mainBar = import ./settings.nix; };
    style = ./style.css;
  };

  # waybar helper scripts -> ~/.config/waybar/scripts/
  xdg.configFile = lib.mapAttrs' (name: _: {
    name = "waybar/scripts/${name}";
    value = {
      source = (./scripts) + "/${name}";
      executable = true;
    };
  }) (lib.filterAttrs (n: t: t == "regular") (builtins.readDir ./scripts));
}
