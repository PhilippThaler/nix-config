{
  config,
  pkgs,
  lib,
  ...
}: {
  programs.mbsync.enable = true;
  programs.msmtp.enable = true;

  # ── Automatic mail sync every 3 minutes ───────────────────
  systemd.user.services.mailsync = {
    Unit = {
      Description = "Sync mail (mbsync -a)";
      After = [ "network-online.target" ];
      Wants = [ "network-online.target" ];
    };
    Service = {
      Type = "oneshot";
      ExecStart = "${pkgs.isync}/bin/mbsync -a";
    };
  };

  systemd.user.timers.mailsync = {
    Unit = {
      Description = "Run mbsync every 3 minutes";
    };
    Timer = {
      OnCalendar = "*:0/3";
      Persistent = true;
    };
    Install.WantedBy = [ "timers.target" ];
  };

  programs.password-store.enable = true;

  programs.gpg.enable = true;
  services.gpg-agent = {
    enable = true;
    pinentry.package = pkgs.pinentry-egui;
    defaultCacheTtl = 1800; # 30min
    maxCacheTtl = 7200; # 2h
  };

  # ── Account: philipp@thaler.fyi (Spacemail) ───────────────────────
  accounts.email = {
    maildirBasePath = ".local/share/mail";

    accounts.spacemail = {
      primary = true;
      realName = "Philipp Thaler";
      address = "philipp@thaler.fyi";
      userName = "philipp@thaler.fyi";

      passwordCommand = "pass show email/philipp@thaler.fyi";

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
        patterns = [ "*" ];
        create = "both";
        expunge = "both";
      };

      notmuch = {
        enable = true;
        neomutt.virtualMailboxes = [ ];
      };

      neomutt = {
        enable = true;
        extraMailboxes = [ "Sent" "Drafts" "Trash" "Archive" "Spam" ];
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
      msmtp.enable = true;

      signature = {
        text = ''
          Mit freundlichen Grüßen
          Philipp Thaler
        '';
        showSignature = "append";
      };

      gpg = {
        key = "FC7404E97136D53E34BB557F3A5D1B1D62B7F9C4";
        signByDefault = true;
      };
    };
  };
}
