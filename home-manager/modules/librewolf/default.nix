{pkgs, ...}: let
  # firenvim
  firenvimHost = pkgs.writeShellScript "firenvim-host" ''
    mkdir -p "$HOME/.local/share/firenvim"
    cd "$HOME/.local/share/firenvim"
    unset NVIM_LISTEN_ADDRESS
    if [ -n "$VIM" ] && [ ! -d "$VIM" ]; then
      unset VIM
    fi
    if [ -n "$VIMRUNTIME" ] && [ ! -d "$VIMRUNTIME" ]; then
      unset VIMRUNTIME
    fi
    export XDG_DATA_HOME="''${XDG_DATA_HOME:-$HOME/.local/share}"
    export XDG_CONFIG_HOME="''${XDG_CONFIG_HOME:-$HOME/.config}"
    export XDG_STATE_HOME="''${XDG_STATE_HOME:-$HOME/.local/state}"
    export XDG_CACHE_HOME="''${XDG_CACHE_HOME:-$HOME/.cache}"
    if command -v nvim >/dev/null 2>&1; then
      FIRENVIM_NVIM_BINARY=nvim
    else
      FIRENVIM_NVIM_BINARY=${pkgs.neovim}/bin/nvim
    fi
    exec "$FIRENVIM_NVIM_BINARY" --headless \
      --cmd "let g:firenvim_config={'globalSettings':{},'localSettings':{'.*':{}}}|let g:firenvim_i=[]|let g:firenvim_o=[]|let g:Firenvim_oi={i,d,e->add(g:firenvim_i,d)}|let g:Firenvim_oo={t->[chansend(2,t)]+add(g:firenvim_o,t)}|let g:firenvim_c=stdioopen({'on_stdin':{i,d,e->g:Firenvim_oi(i,d,e)},'on_print':{t->g:Firenvim_oo(t)}})" \
      --cmd 'let g:started_by_firenvim = v:true' \
      -c 'try|call firenvim#run()|catch /Unknown function/|call chansend(g:firenvim_c,["f\n\n\n"..json_encode({"messages":["Your plugin manager did not load the Firenvim plugin for Neovim."],"version":"0.0.0"})])|qall!|catch|call chansend(g:firenvim_c,["l\n\n\n"..json_encode({"messages":["Something went wrong when running firenvim. See troubleshooting guide."],"version":"0.0.0"})])|qall!|endtry'
  '';
in {
  home.file = {
    ".config/librewolf/librewolf/4v0kc0t8.default/chrome/userChrome.css".source = ./userChrome.css;
    # TST config snapshot (exported via TST options); re-import in TST options after profile reset
    ".config/librewolf/librewolf/4v0kc0t8.default/tst-config.json".source = ./tst-config.json;
    ".librewolf/native-messaging-hosts/firenvim.json".text = builtins.toJSON {
      name = "firenvim";
      description = "Turn your browser into a Neovim GUI.";
      path = "${firenvimHost}";
      type = "stdio";
      allowed_extensions = ["firenvim@lacamb.re"];
    };
    ".config/librewolf/librewolf/4v0kc0t8.default/user.js".text = ''
      user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);
      # firenvim: Local Network Access blocks the frame's ws://127.0.0.1:port connection
      user_pref("network.lna.websocket.enabled", false);
    '';
  };

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
