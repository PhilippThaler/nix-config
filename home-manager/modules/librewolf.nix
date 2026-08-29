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
}
