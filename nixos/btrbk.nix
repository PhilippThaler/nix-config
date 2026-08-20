# btrbk: btrfs snapshots of /home + off-machine send to home server (10.69.20.50)
#
# - Local snapshots of the `home` subvolume live in /btrbk_snapshots (7 days).
# - Snapshots are sent incrementally to the server's dedicated btrfs disk
#   (/mnt/disk5/backup/x1c, 14 daily + 4 weekly retained).
# - ~/Nextcloud is its own subvolume (home/philipp/Nextcloud) and is therefore
#   excluded automatically: btrfs snapshots/sends never cross subvolume
#   boundaries (it is synced to the server by Nextcloud anyway).
{ ... }:

{
  services.btrbk.instances.main = {
    onCalendar = "daily";
    settings = {
      snapshot_preserve_min = "2d";
      snapshot_preserve = "7d";
      target_preserve_min = "no";
      target_preserve = "14d 4w";

      ssh_identity = "/root/.ssh/btrbk_key";
      ssh_user = "philipp";

      volume."/" = {
        snapshot_dir = "/btrbk_snapshots";
        target = "ssh://10.69.20.50/mnt/disk5/backup/x1c";
        subvolume.home = {
          snapshot_create = "always";
        };
      };
    };
  };

  # btrbk does not create snapshot_dir itself
  systemd.tmpfiles.rules = [
    "d /btrbk_snapshots 0755 root root -"
  ];
}
