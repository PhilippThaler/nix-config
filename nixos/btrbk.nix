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
      outlog=$(mktemp)
      errlog=$(mktemp)
      trap 'rm -f "$outlog" "$errlog"' EXIT

      # Progress goes to the journal, and both streams are kept: the "Backup
      # Summary" that names the sent snapshot is printed on stdout, errors on stderr.
      set +e
      btrbk -c /etc/btrbk/main.conf run 2> "$errlog" | tee "$outlog" >&2
      status=''${PIPESTATUS[0]}
      set -e

      cat "$errlog" >&2

      push() {
        curl --silent --show-error --fail --max-time 20 --get \
          "$(head -n 1 ${lib.escapeShellArg kumaPushUrl})" \
          --data-urlencode "status=$1" \
          --data-urlencode "msg=$2" || true
      }

      if [ "$status" -eq 0 ]; then
        local_snap=$(find /btrbk_snapshots -maxdepth 1 -name 'home.*' -printf '%f\n' 2>/dev/null | sort -r | head -n 1 || true)
        # ">>> /path/home.<date>" is a received subvolume (incremental), "*** ..."
        # a received one (non-incremental): either means this run sent something.
        sent_line=$(grep -E '^(>>> |[*][*][*] )' "$outlog" 2>/dev/null | tail -n 1 || true)

        if [ -n "$sent_line" ]; then
          sent_snap=''${sent_line##*/}
          push up "sent ''${sent_snap:-?} (local ''${local_snap:-unknown})"
        else
          # Nothing was received, so nothing was sent. The summary only names a
          # target subvolume when one was deleted ("--- /mnt/disk5/backup/x1c/home.<date>").
          target_snap=$(grep -E '^--- ' "$outlog" 2>/dev/null | sed -E 's|^--- ||' | grep -Ev '^/btrbk_snapshots/' | sed -E 's|.*/||' | sort -r | head -n 1 || true)
          push up "nothing to send (local ''${local_snap:-unknown}, target ''${target_snap:-?})"
        fi
      else
        msg=$(head -n 1 "$errlog")
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
