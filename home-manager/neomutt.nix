# NeoMutt client preferences.
#
# Architecture: mutt-wizard's upstream default muttrc (share/mutt-wizard.muttrc)
# is shipped as the BASE config and sourced first, so neomutt gets all of
# mutt-wizard's stock settings, keybindings, sidebar setup and macros. Everything
# we differ on is layered on top here in programs.neomutt.extraConfig (colors,
# mbsync sync, Spam box, address-book/GPG-WKS removal, signature, etc).
#
#   base file : ~/.config/neomutt/mutt-wizard.muttrc  (pinned upstream, via home.file)
#   overrides : programs.neomutt.extraConfig below
#
# Account wiring (identity, IMAP/SMTP, gpg signing key, cache dirs) lives in
# email.nix (accounts.email).
{
  pkgs,
  ...
}: {
  # mutt-wizard's defaults integrate these: lynx renders HTML, notmuch powers
  # the Ctrl-F search macro from the base muttrc.
  home.packages = [
    pkgs.lynx
    pkgs.notmuch
  ];

  # notmuch indexes ~/Maildir (accounts.email.maildirBasePath) automatically.
  programs.notmuch = {
    enable = true;
  };

  programs.neomutt = {
    enable = true;
    sidebar.enable = true;
    # vimKeys intentionally OFF: mutt-wizard's base muttrc already ships its own
    # vi-style bindings (gg/G, j/k, d/u, l/h, g-prefix folder jumps). HM's
    # vim-keys.rc also binds gT/dT/dd with `d noop`, which directly conflicts
    # with the base's `bind d half-down` (and its alias-warnings would fail the
    # source). Letting the base own the bindings avoids the clash.

    extraConfig = ''
      # Ship mutt-wizard's defaults as the base, then override below.
      source ~/.config/neomutt/mutt-wizard.muttrc

      # ── Composition / safety (custom, ported from old config) ──────
      set sig_on_top = yes
      set abort_noattach = yes
      set abort_noattach_regex = "\\<(anhängen|angehängt|anhang|anhänge|hängt an|attach(|ed|ments?))\\>"
      set date_format = "%Y-%m-%d %H:%M"          # overrides mutt-wizard default
      set attach_save_dir = "~/attachments/"
      set display_filter = "tac | sed '/\\\[-- Autoview/,+1d' | tac" # hide autoview msgs
      alias me Philipp Thaler <philipp@thaler.fyi>

      # arrow keys in the pager
      bind pager <up> previous-line
      bind pager <down> next-line

      # ── Sync: mbsync replaces mutt-wizard's `mailsync` script ───────
      macro index o "<shell-escape>mbsync -a<enter>" "sync all mail"
      macro index O "<shell-escape>mbsync -a<enter>" "sync all mail"

      # A = mark all new as read (mutt-wizard's default A = show all / undo limit)
      macro index A \
          "<tag-pattern>~N<enter><tag-prefix><clear-flag>N<untag-pattern>.<enter>" \
          "mark all new as read"

      # Spam box — upstream uses Junk; add Spam go-to/move/copy variants (M/C are
      # already noop'd by the base muttrc so these don't alias-warn).
      macro index,pager gS "<change-folder>=Spam<enter>" "go to spam"
      macro index,pager MS ";<save-message>=Spam<enter>" "move mail to spam"
      macro index,pager CS ";<copy-message>=Spam<enter>" "copy mail to spam"

      # abook is not installed — drop mutt-wizard's address-book integration
      unset query_command
      unmacro index,pager a

      # GPG WKS publish/receive macros need gpg-wks-client + a WKS provider
      unmacro index \eg
      unmacro index \eh

      # ── ics/calendar viewing ────────────────────────────────────────
      auto_view text/calendar application/ics
      alternative_order text/calendar text/plain text/enriched text/html
      set show_multipart_alternative = inline

      # ── Theme: Catppuccin Frappe (overrides the base default palette) ─
      # Indexed colorN values follow kitty's palette (current-theme.conf = Frappe).
      # Explicit #RRGGBB would need setrgbf/setrgbb, which NixOS's xterm-kitty
      # terminfo lacks, so neomutt disables direct colour and errors on hex.
      color normal          default default
      color index           color2 default ~N
      color index           color1 default ~F
      color index           color13 default ~T
      color index           color1 default ~D
      color attachment      color5 default
      color signature       color8 default
      color search          color4 default

      color indicator       default color8
      color error           color1 default
      color status          color15 default
      color tree            color15 default
      color tilde           color15 default

      color hdrdefault      color13 default
      color header          color13 default "^From:"
      color header          color13 default "^Subject:"

      color quoted          color15 default
      color quoted1         color7 default
      color quoted2         color8 default
      color quoted3         color0 default
      color quoted4         color0 default
      color quoted5         color0 default

      color body  color2 default [\-\.+_a-zA-Z0-9]+@[\-\.a-zA-Z0-9]+
      color body  color2 default (https?|ftp)://[\-\.,/%~_:?&=\#a-zA-Z0-9]+
      color body  color4 default (^|[[:space:]])[*][^[:space:]]+[*]([[:space:]]|$)
      color body  color4 default (^|[[:space:]])_[^[:space:]]+_([[:space:]]|$)
      color body  color4 default (^|[[:space:]])/[^[:space:]]+/([[:space:]]|$)

      color sidebar_flagged color1 default
      color sidebar_new     color10 default
    '';
  };

  # rofi launches neomutt inside kitty (it's a TUI).
  xdg.desktopEntries.neomutt = {
    name = "NeoMutt";
    genericName = "Email Client";
    comment = "Terminal email client";
    exec = "kitty -e neomutt";
    terminal = false; # exec already wraps neomutt in kitty
    categories = [ "Network" "Email" ];
  };

  # ── base file: mutt-wizard's default muttrc, pinned to a commit ────
  home.file.".config/neomutt/mutt-wizard.muttrc".source =
    builtins.fetchurl {
      url = "https://raw.githubusercontent.com/LukeSmithxyz/mutt-wizard/b4a28b2548e94c167bb74fcb5e8c44c34d2be842/share/mutt-wizard.muttrc";
      sha256 = "sha256-Il3HWitdnwq5xoXS5pE8+Ve6iuXMaY/qNtrWwN7K8f0=";
    };

  # ── mailcap (attachment handling) ─────────────────────────────────
  home.file.".config/mutt/mailcap".text = ''
    text/plain; $EDITOR %s ;
    text/html; lynx -assume_charset=%{charset} -display_charset=utf-8 -dump -width=1024 %s; nametemplate=%s.html; copiousoutput;
    application/pdf; zathura %s ;
    application/pgp-encrypted; gpg -d '%s'; copiousoutput;
    application/pgp-keys; gpg --import '%s'; copiousoutput;
    video/*; setsid mpv --quiet %s &; copiousoutput
    audio/*; mpv %s ;
    image/*; imv %s ;
  '';
}
