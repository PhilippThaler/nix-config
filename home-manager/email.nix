# Email stack — declarative replacement for mutt-wizard.
#
# mutt-wizard = neomutt (client) + mbsync (IMAP sync) + msmtp (SMTP) + pass (passwords).
# Home Manager's `accounts.email` module wires all four together from this file.
#
# After `nixrebuild`:
#   1. First sync:   mbsync -a        (mail lands in ~/Maildir/spacemail/)
#   2. Client:       neomutt          (opens with this account sourced)
#
# If the server's folder names differ (Sent/Drafts/Trash), fix them below in
# `folders` or change `mbsync.patterns`; check with `mbsync -l spacemail-remote`.
{
  config,
  pkgs,
  lib,
  ...
}: {
  # ── Client / sync / send ──────────────────────────────────────────
  programs.neomutt = {
    enable = true;
    sidebar.enable = true;
    vimKeys = true;
  };

  programs.mbsync.enable = true; # isync — pulls IMAP → ~/Maildir
  programs.msmtp.enable = true; # sends via SMTP

  # ── Passwords: pass (passwordstore) ───────────────────────────────
  programs.password-store.enable = true; # pass CLI + extensions

  # ── GPG — required by pass (store encryption) and neomutt (signing) ──
  programs.gpg.enable = true; # installs gnupg, sane ~/.gnupg/gpg.conf (0700)
  services.gpg-agent = {
    enable = true; # passphrase caching; neomutt expects the agent
    defaultCacheTtl = 1800; # 30 min
    maxCacheTtl = 7200; # 2 h
  };

  # ── Account: philipp@thaler.fyi (Spacemail) ───────────────────────
  accounts.email = {
    maildirBasePath = "Maildir"; # → ~/Maildir/<account>/

    accounts.spacemail = {
      primary = true; # exactly one account must be primary
      realName = "Philipp Thaler";
      address = "philipp@thaler.fyi";
      userName = "philipp@thaler.fyi";

      # mutt-wizard layout: pass entries live under email/<address>
      # (store lives at ~/.password-store, pass's default)
      passwordCommand = "pass show email/philipp@thaler.fyi";

      # Spacemail (spaceship.com) server settings
      imap = {
        host = "mail.spacemail.com";
        port = 993;
        tls.enable = true;
      };

      smtp = {
        host = "mail.spacemail.com";
        port = 465;
        tls.enable = true;
      };

      mbsync = {
        enable = true;
        patterns = [ "*" ]; # sync all server folders
        create = "both"; # create missing local + remote mailboxes
        expunge = "both";
      };

      neomutt.enable = true;
      msmtp.enable = true; # generate an msmtp account entry for this account

      # Message signing/encryption. To enable, run `gpg --list-keys`, set your
      # key id below and uncomment:
      # gpg = {
      #   key = "ABCDEF1234567890";
      #   signByDefault = true;
      # };
    };
  };
}
