let
  host = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEq3VC9XpJqSZ1Kyxy/nsvlW3/iWf9sm/8xCDxag4Y6Y";
  user = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMFW1aBqD+NXREf2XJumAyrsyIYSC8J09P6VnWYZV6WH philipp@philipp-laptop";

  recipients = [host user];
in {
  "btrbk_key.age".publicKeys = recipients;
  "id_ed25519.age".publicKeys = recipients;
  "ansible_key.age".publicKeys = recipients;
  "mail_password.age".publicKeys = recipients;
  "gpg_key.age".publicKeys = recipients;
}
