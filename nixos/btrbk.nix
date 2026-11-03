# btrbk: btrfs snapshots of /home + off-machine send to home server (10.69.20.50)
#
# - Local snapshots of the `home` subvolume live in /btrbk_snapshots (7 days).
# - Snapshots are sent incrementally to the server's dedicated btrfs disk
#   (/mnt/disk5/backup/x1c, 14 daily + 4 weekly retained).
# - ~/Nextcloud is its own subvolume (home/philipp/Nextcloud) and is therefore
#   excluded automatically: btrfs snapshots/sends never cross subvolume
#   boundaries (it is synced to the server by Nextcloud anyway).
# - Every run reports its own result to the Uptime Kuma push monitor
#   "btrbk backups (X1C)", so a missed or failed backup alerts from this host.
{
  config,
  lib,
  pkgs,
  ...
}: let
  kumaPushUrl = config.age.secrets.kuma_btrbk_push_url.path;

  btrbkRun = pkgs.writeShellApplication {
    name = "btrbk-run";
    runtimeInputs = [pkgs.btrbk pkgs.coreutils pkgs.curl pkgs.findutils];
    text = ''
      log=$(mktemp)
      trap 'rm -f "$log"' EXIT

      # btrbk keeps streaming its progress to the journal on stdout; errors go
      # to stderr, which is kept to build the alert message and replayed after.
      set +e
      btrbk -c /etc/btrbk/main.conf run >&2 2> "$log"
      status=$?
      set -e

      cat "$log" >&2

      push() {
        curl --silent --show-error --fail --max-time 20 --get \
          "$(head -n 1 ${lib.escapeShellArg kumaPushUrl})" \
          --data-urlencode "status=$1" \
          --data-urlencode "msg=$2" || true
      }

      if [ "$status" -eq 0 ]; then
        newest=$(find /btrbk_snapshots -maxdepth 1 -name 'home.*' -printf '%f\n' 2>/dev/null | sort -r | head -n 1 || true)
        push up "''${newest:-unknown}"
      else
        msg=$(head -n 1 "$log")
        push down "''${msg:-btrbk exit $status}"
      fi

      exit "$status"
    '';
  };
in {
  services.btrbk.instances.main = {
    onCalendar = "daily";
    settings = {
      backend = "btrfs-progs-sudo";
      stream_compress = "zstd";

      snapshot_preserve_min = "2d";
      snapshot_preserve = "7d";
      target_preserve_min = "no";
      target_preserve = "14d 4w";

      ssh_identity = config.age.secrets.btrbk_key.path;
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

  # mkForce, so the wrapper replaces the module's ExecStart instead of adding a
  # second one (a oneshot unit would run both).
  systemd.services."btrbk-main".serviceConfig.ExecStart = lib.mkForce "${btrbkRun}/bin/btrbk-run";

  # btrbk does not create snapshot_dir itself
  systemd.tmpfiles.rules = [
    "d /btrbk_snapshots 0755 root root -"
  ];
}
