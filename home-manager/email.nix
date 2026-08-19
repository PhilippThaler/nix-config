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
  # Client prefs (colors, macros, keybindings, theme) live in neomutt.nix.
  programs.mbsync.enable = true; # isync — pulls IMAP → ~/Maildir
  programs.msmtp.enable = true; # sends via SMTP

  # ── Passwords: pass (passwordstore) ───────────────────────────────
  programs.password-store.enable = true; # pass CLI + extensions

  # ── GPG — required by pass (store encryption) and neomutt (signing) ──
  programs.gpg.enable = true; # installs gnupg, sane ~/.gnupg/gpg.conf (0700)
  services.gpg-agent = {
    enable = true; # passphrase caching; neomutt expects the agent
    pinentry.package = pkgs.pinentry-egui; # modern egui dialog (wayland/X11 via winit)
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

      neomutt = {
        enable = true;
        # HM's account.gpg module sets crypt_autosign but IGNORES gpg.key, so
        # the signing key must be wired in here explicitly (signing subkey [S]).
        # Account-scoped crypt + cache settings ported from old account muttrc.
        extraConfig = ''
          set pgp_sign_as = "FC7404E97136D53E34BB557F3A5D1B1D62B7F9C4"
          set pgp_default_key = "FC7404E97136D53E34BB557F3A5D1B1D62B7F9C4"

          set crypt_verify_sig = yes
          set crypt_autopgp = yes
          set crypt_autoencrypt = no
          set crypt_opportunistic_encrypt = yes
          set postpone_encrypt = yes
          set pgp_self_encrypt = yes
          set crypt_use_pka = no

          set header_cache = "~/.cache/mutt/headers"
          set message_cachedir = "~/.cache/mutt/bodies"
          set hostname = "thaler.fyi"
        '';
      };
      msmtp.enable = true; # generate an msmtp account entry for this account

      # German signature (ported from ~/dotfiles/mutt). showSignature must be
      # non-"none" or HM emits `unset signature`.
      signature = {
        text = ''
          Mit freundlichen Grüßen
          Philipp Thaler
        '';
        showSignature = "append";
      };

      # Sign outbound mail (sets crypt_autosign = yes in neomutt).
      gpg = {
        key = "FC7404E97136D53E34BB557F3A5D1B1D62B7F9C4";
        signByDefault = true;
      };
    };
  };
}
