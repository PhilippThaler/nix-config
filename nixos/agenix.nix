{...}: {
  age.secrets = {
    # Dedicated, passphrase-less backup key for pushing snapshots to the server.
    # Owned by the `btrbk` service user, since services.btrbk runs the send as it.
    btrbk_key = {
      file = ../secrets/btrbk_key.age;
      owner = "btrbk";
      group = "btrbk";
      mode = "0400";
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
    # WireGuard private + preshared key as an env file for the NM profile
    wg_keys = {
      file = ../secrets/wg_keys.age;
      owner = "root";
      group = "root";
      mode = "0400";
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
