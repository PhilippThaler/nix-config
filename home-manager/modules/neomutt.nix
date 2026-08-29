{
  pkgs,
  ...
}: {
  home.packages = [
    pkgs.lynx
    pkgs.notmuch
    pkgs.urlscan
  ];

  programs.notmuch.enable = true;
  programs.neomutt = {
    enable = true;
    sidebar.enable = true;
    sort = "reverse-date";
    extraConfig = ''
      source ~/.config/neomutt/mutt-wizard.muttrc

      set sig_on_top = yes
      set abort_noattach = yes
      set abort_noattach_regex = "\\<(anhängen|angehängt|anhang|anhänge|hängt an|attach(|ed|ments?))\\>"
      set date_format = "%Y-%m-%d %H:%M"
      set attach_save_dir = "~/attachments/"
      set display_filter = "tac | sed '/\\\[-- Autoview/,+1d' | tac"
      alias me Philipp Thaler <philipp@thaler.fyi>

      set query_command = "echo ''' && notmuch address from:/%s/"

      bind pager <up> previous-line
      bind pager <down> next-line

      macro index o "<shell-escape>mbsync -a<enter>" "sync all mail"
      macro index O "<shell-escape>mbsync -a<enter>" "sync all mail"

      macro index A \
          "<tag-pattern>~U<enter><tag-prefix><clear-flag>N<untag-pattern>.<enter>" \
          "mark all unread as read"


      macro index,pager \cb \
          "<pipe-message> urlscan<Enter>" \
          "call urlscan to extract URLs out of a message"
      macro attach,compose \cb \
          "<pipe-entry> urlscan<Enter>" \
          "call urlscan to extract URLs out of a message"

      macro index,pager gS "<change-folder>=Spam<enter>" "go to spam"
      macro index,pager MS ";<save-message>=Spam<enter>" "move mail to spam"
      macro index,pager CS ";<copy-message>=Spam<enter>" "copy mail to spam"
      macro index,pager gi "<change-folder>=Inbox<enter>" "go to inbox"
      macro index,pager Mi ";<save-message>=Inbox<enter>" "move mail to inbox"
      macro index,pager Ci ";<copy-message>=Inbox<enter>" "copy mail to inbox"

      unmacro index,pager a
      unmacro index \eg
      unmacro index \eh

      auto_view text/calendar application/ics
      alternative_order text/calendar text/plain text/enriched text/html
      set show_multipart_alternative = inline

      # Catppuccin Frappe, via kitty's 16-color palette (current-theme.conf).
      # color0 = unread bg (Surface 1), color8 = cursor bg (Surface 2).
      color normal          default default
      color index           color7 color0 ~U
      color index           color2 color0 ~N
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

  xdg.desktopEntries.neomutt = {
    name = "NeoMutt";
    genericName = "Email Client";
    comment = "Terminal email client";
    exec = "kitty -e neomutt";
    terminal = false;
    categories = [ "Network" "Email" ];
  };

  # mutt-wizard's default muttrc, pinned to a commit so it can't drift.
  home.file.".config/neomutt/mutt-wizard.muttrc".source =
    builtins.fetchurl {
      url = "https://raw.githubusercontent.com/LukeSmithxyz/mutt-wizard/b4a28b2548e94c167bb74fcb5e8c44c34d2be842/share/mutt-wizard.muttrc";
      sha256 = "sha256-Il3HWitdnwq5xoXS5pE8+Ve6iuXMaY/qNtrWwN7K8f0=";
    };

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
