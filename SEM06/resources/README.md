# Supplementary resources

The `systemd/` directory contains example Monitor and Backup units and a Backup timer. `examples/cron_examples.txt` is a reference containing alternative schedules; it is not an installable crontab. `templates/bash_script_template.sh` is an executable scaffold, with a deliberate NOT_IMPLEMENTED status until application logic is supplied.

## Match units to the supplied CLI

Monitor runs a foreground loop with `--daemon --interval 60`, so `Type=simple` supervises the actual process. Its single-shot form has no `--all` switch. Backup is a bounded `Type=oneshot` invocation with `--type daily --incremental --compression gz`; it has no `create`, `rotate`, `--compress` or `--type incremental` interface. Both use separate option/value arguments. See each current `--help` and project README.

The example account `capstone`, `/opt/ENos`, `/srv/capstone/source` and `/etc/capstone/*.conf` are placeholders to provision and review before any activation. Configure literal paths, a writable runtime lock, logs and owned data explicitly. The unit's configuration cannot silently point at unrelated data. The provided hardening settings are examples, not proof that the chosen host configuration will run successfully.

## Read-only preparation

From the repository root:

```bash
bash SEM06/scripts/projects/monitor/monitor.sh --help
bash SEM06/scripts/projects/backup/backup.sh --help
systemd-analyze calendar '*-*-* 03:00:00'
systemd-analyze verify SEM06/resources/systemd/monitor.service SEM06/resources/systemd/backup.service SEM06/resources/systemd/backup.timer
```

`verify` can report absent example accounts, executables, configuration or host dependencies. Parsing and calendar checks do not establish successful scheduling, permissions, restart behaviour or native service operation. A sample unit may need adjusted restrictions for an authorised deployment. `RandomizedDelaySec=1800` adds 0–30 minutes; `AccuracySec=1min` can add scheduling slack.

## Activation (separate host action)

After reviewing and provisioning paths, accounts, dependencies and permissions, an authorised administrator can copy the selected units into the host's systemd directory, run `systemctl daemon-reload`, then enable/start the Monitor service or Backup timer. These are consequential host operations; local repository verification does not perform them. Keep a rollback copy of previous unit/configuration files and inspect `systemctl status`, `journalctl -u ...` and `systemctl list-timers` after activation. Enable the timer for recurring Backup, not a guessed unsupported CLI.

## Script template

```bash
# Choose an owned project directory first; an existing file is not overwritten.
target=${1:?Supply an owned new script path}
[[ ! -e $target && ! -L $target ]] || exit 1
cp -- SEM06/resources/templates/bash_script_template.sh "$target"
bash "$target" --help
```

The template contains CLI validation, literal configuration and owned cleanup. TODO logic remains an exercise. The current local helper implementations and bounded demonstrations are in `scripts/examples/`; no `check_dependencies.sh` or cloned external project is required by this resource guide.

## Primary references

- GNU Project. *Bash reference manual*. https://www.gnu.org/software/bash/manual/
- systemd. *systemd.service*, *systemd.timer* and *systemd.exec*. https://www.freedesktop.org/software/systemd/man/latest/
- Linux man-pages. *crontab(5)*. https://man7.org/linux/man-pages/man5/crontab.5.html

No service, cron entry, email, webhook or remote deployment is activated by these examples.
