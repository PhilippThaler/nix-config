{
  ...
}: {
  # LibreWolf with Tree Style Tabs (installed via enterprise policy,
  # same mechanism LibreWolf itself uses for its bundled uBlock Origin)
  programs.librewolf = {
    enable = true;
    policies.ExtensionSettings."treestyletab@piro.sakura.ne.jp" = {
      installation_mode = "normal_installed";
      install_url = "https://addons.mozilla.org/firefox/downloads/latest/treestyletab/latest.xpi";
    };
  };
}