{...}: {
  age.secrets = {
    # Dedicated, passphrase-less backup key used by the btrbk service (root) to
    # push snapshots to the server. Root-only, so it cannot be used interactively.
    btrbk_key = {
      file = ../secrets/btrbk_key.age;
      owner = "root";
      group = "root";
      mode = "0600";
    };
    # Personal SSH identity (passphrase = login password, unlocked by pam_gnupg)
    id_ed25519 = {
      file = ../secrets/id_ed25519.age;
      owner = "philipp";
      group = "users";
      mode = "0600";
    };
    # Ansible homelab key (passphrase = login password, unlocked by pam_gnupg)
    ansible_key = {
      file = ../secrets/ansible_key.age;
      owner = "philipp";
      group = "users";
      mode = "0600";
    };
    # IMAP/SMTP password for philipp@thaler.fyi (neomutt/mbsync/msmtp)
    mail_password = {
      file = ../secrets/mail_password.age;
      owner = "philipp";
      group = "users";
      mode = "0600";
    };
    # GPG signing subkey, imported into philipp's keyring by a user service
    gpg_key = {
      file = ../secrets/gpg_key.age;
      owner = "philipp";
      group = "users";
      mode = "0600";
    };
  };
}
