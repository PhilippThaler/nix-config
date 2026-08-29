{pkgs, ...}: {
  programs.librewolf = {
    enable = true;
    globalExtensions = with pkgs.nur.repos.rycee.firefox-addons; [
      ublock-origin
      tree-style-tab
      darkreader
      istilldontcareaboutcookies
      bitwarden
      facebook-container
      enhancer-for-youtube
      reduxdevtools
      reddit-enhancement-suite
      imagus
      spoof-timezone
      old-reddit-redirect
      vimium
      firenvim
    ];
  };

  home.file = {
    ".config/librewolf/librewolf/4v0kc0t8.default/chrome/userChrome.css".source = ../dotfiles/librewolf/userChrome.css;
    ".config/librewolf/librewolf/4v0kc0t8.default/user.js".text = ''
      user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);
    '';
  };
}
