# NeoMutt client preferences — ported from ~/dotfiles/mutt/.config/mutt/muttrc.
#
# Account wiring (identity, IMAP/SMTP, gpg signing key, cache dirs) lives in
# email.nix (accounts.email). This file holds the global client customisation:
# colors/theme, keybindings + macros, and misc settings.
{
  ...}: {
  programs.neomutt = {
    enable = true;
    sidebar.enable = true;
    vimKeys = true;

    extraConfig = ''
      # ── rofi launcher: wrap the TUI in a terminal ──────────────────
      set mailcap_path = "~/.config/mutt/mailcap"

      # ── Composition / safety ───────────────────────────────────────
      set sig_on_top = yes
      set abort_noattach = yes
      set abort_noattach_regex = "\\<(anhängen|angehängt|anhang|anhänge|hängt an|attach(|ed|ments?))\\>"
      set date_format = "%Y-%m-%d %H:%M"
      set attach_save_dir = "~/attachments/"
      set display_filter = "tac | sed '/\\\[-- Autoview/,+1d' | tac" # hide autoview messages
      alternative_order text/plain text/enriched text/html

      alias me Philipp Thaler <philipp@thaler.fyi>

      # ── Pager / attachment bindings ────────────────────────────────
      bind attach <return> view-mailcap
      bind pager <up> previous-line
      bind pager <down> next-line

      # ── Overview macros ────────────────────────────────────────────
      macro index O "<shell-escape>mbsync -a<enter>" "sync all mail"

      macro index A \
          "<tag-pattern>~N<enter><tag-prefix><clear-flag>N<untag-pattern>.<enter>" \
          "mark all new as read"

      # ── Go-to-folder macros ────────────────────────────────────────
      macro index,pager gi "<change-folder>=INBOX<enter>" "go to inbox"
      macro index,pager gd "<change-folder>=Drafts<enter>" "go to drafts"
      macro index,pager gj "<change-folder>=Junk<enter>" "go to junk"
      macro index,pager gt "<change-folder>=Trash<enter>" "go to trash"
      macro index,pager gS "<change-folder>=Spam<enter>" "go to spam"
      macro index,pager gs "<change-folder>=Sent<enter>" "go to sent"
      macro index,pager ga "<change-folder>=Archive<enter>" "go to archive"

      # ── Move / copy to folder ──────────────────────────────────────
      # Neomutt warns that multi-key macros Mi/Ci/… alias the default M/C
      # prefixes; unbind them first to silence the warning.
      bind index M noop
      bind index C noop
      bind pager M noop
      bind pager C noop
      macro index,pager Mi ";<save-message>=INBOX<enter>" "move mail to inbox"
      macro index,pager Ci ";<copy-message>=INBOX<enter>" "copy mail to inbox"
      macro index,pager Md ";<save-message>=Drafts<enter>" "move mail to drafts"
      macro index,pager Cd ";<copy-message>=Drafts<enter>" "copy mail to drafts"
      macro index,pager Mj ";<save-message>=Junk<enter>" "move mail to junk"
      macro index,pager Cj ";<copy-message>=Junk<enter>" "copy mail to junk"
      macro index,pager Mt ";<save-message>=Trash<enter>" "move mail to trash"
      macro index,pager Ct ";<copy-message>=Trash<enter>" "copy mail to trash"
      macro index,pager MS ";<save-message>=Spam<enter>" "move mail to spam"
      macro index,pager CS ";<copy-message>=Spam<enter>" "copy mail to spam"
      macro index,pager Ms ";<save-message>=Sent<enter>" "move mail to sent"
      macro index,pager Cs ";<copy-message>=Sent<enter>" "copy mail to sent"
      macro index,pager Ma ";<save-message>=Archive<enter>" "move mail to archive"
      macro index,pager Ca ";<copy-message>=Archive<enter>" "copy mail to archive"

      # ── ics/calendar viewing ───────────────────────────────────────
      auto_view text/calendar application/ics
      alternative_order text/calendar text/plain text/enriched text/html
      set show_multipart_alternative = inline

      # ── Theme: Catppuccin (via kitty's 16-color palette, Frappe) ────
      # These indexed colorN values follow the terminal's palette, so they only
      # look right because kitty.conf includes current-theme.conf = Frappe.
      # (Explicit #RRGGBB would be nicer but NixOS's xterm-kitty terminfo lacks
      # setrgbf/setrgbb, so neomutt disables direct colour and errors on hex.)
      color normal          default default   # Text is "Text"
      color index           color2 default ~N       # New Messages are Green
      color index           color1 default ~F       # Flagged messages are Red
      color index           color13 default ~T      # Tagged Messages are Red
      color index           color1 default ~D       # Messages to delete are Red
      color attachment      color5 default          # Attachments are Pink
      color signature       color8 default          # Signatures are Surface 2
      color search          color4 default          # Highlighted results are Blue

      color indicator       default color8          # highlighted message (Surface 2 bg)
      color error           color1 default          # error messages are Red
      color status          color15 default         # status line "Subtext 0"
      color tree            color15 default         # thread tree arrows Subtext 0
      color tilde           color15 default         # blank line padding Subtext 0

      color hdrdefault      color13 default         # default headers Pink
      color header          color13 default "^From:"
      color header          color13 default "^Subject:"

      color quoted          color15 default         # Subtext 0
      color quoted1         color7 default          # Subtext 1
      color quoted2         color8 default          # Surface 2
      color quoted3         color0 default          # Surface 1
      color quoted4         color0 default
      color quoted5         color0 default

      color body  color2 default [\-\.+_a-zA-Z0-9]+@[\-\.a-zA-Z0-9]+             # email addresses Green
      color body  color2 default (https?|ftp)://[\-\.,/%~_:?&=\#a-zA-Z0-9]+      # URLs Green
      color body  color4 default (^|[[:space:]])[*][^[:space:]]+[*]([[:space:]]|$)  # *bold* text Blue
      color body  color4 default (^|[[:space:]])_[^[:space:]]+_([[:space:]]|$)      # _underlined_ text Blue
      color body  color4 default (^|[[:space:]])/[^[:space:]]+/([[:space:]]|$)      # /italic/ text Blue

      color sidebar_flagged color1 default    # Mailboxes with flagged mails are Red
      color sidebar_new     color10 default   # Mailboxes with new mail are Green
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
