"""Local semantic regressions. Native service/network acceptance is outside scope."""
from pathlib import Path
import json
import os
import shlex
import subprocess
import tempfile
import unittest

PROJECTS=Path(__file__).resolve().parents[1]/'scripts/projects'


class RuntimeSemantics(unittest.TestCase):
    def test_backup_full_incremental_mutations_and_corruption(self):
        with tempfile.TemporaryDirectory(prefix='enos-backup-test-') as td:
            root=Path(td);source=root/'source with spaces';source.mkdir()
            for name,text in {'modified':'before','deleted':'old','renamed':'same','skip.tmp':'omit'}.items():
                (source/name).write_text(text)
            dest=root/'archives';config=root/'backup.conf'
            config.write_text(f'BACKUP_SOURCES=("{source}")\nBACKUP_DEST="{dest}"\nLOG_DIR="{root}/logs"\nLOG_FILE="{root}/logs/log"\nLOCK_FILE="{root}/run/lock"\nEXCLUDE_PATTERNS=("*.tmp")\n')
            def run(*args, expected=0):
                p=subprocess.run(['bash',str(PROJECTS/'backup/backup.sh'),'-c',str(config),*map(str,args)],capture_output=True,text=True,timeout=15)
                self.assertEqual(p.returncode,expected,p.stderr)
            before=sorted(str(p.relative_to(root)) for p in root.rglob('*'))
            run('--dry-run')
            self.assertEqual(before,sorted(str(p.relative_to(root)) for p in root.rglob('*')))
            run('--incremental','--type','daily')
            (source/'modified').write_text('after');(source/'deleted').unlink();(source/'renamed').rename(source/'new name');(source/'added').write_text('new')
            run('--incremental','--type','daily')
            latest=dest/(dest/'.latest').read_text().strip()
            self.assertTrue(latest.with_name(latest.name+'.parent').read_text().strip())
            restore=root/'restore';run('--restore',latest,'--restore-dir',restore)
            restored=restore/str(source).lstrip('/')
            self.assertEqual({p.name:p.read_bytes() for p in source.iterdir() if p.suffix!='.tmp'}, {p.name:p.read_bytes() for p in restored.iterdir()})
            with latest.open('ab') as handle:handle.write(b'tampered')
            run('--restore',latest,'--restore-dir',root/'refused',expected=1)
            self.assertFalse((root/'refused').exists())

    def test_retention_complete_chains_and_bad_graph(self):
        with tempfile.TemporaryDirectory(prefix='enos-retention-test-') as td:
            root=Path(td)
            # DERIVED graph fixtures; rotation is tested independently of tar encoding.
            for name,parent in [('backup_daily_old.tar',''),('backup_daily_delta.tar','backup_daily_old.tar'),('backup_daily_new.tar','')]:
                (root/name).write_text('fixture');(root/(name+'.parent')).write_text(parent+'\n');(root/(name+'.sha256')).write_text('fixture')
            os.utime(root/'backup_daily_old.tar',(1,1));os.utime(root/'backup_daily_new.tar',(2,2))
            (root/'.latest').write_text('backup_daily_new.tar\n')
            script=PROJECTS/'backup/lib/retention.py'
            p=subprocess.run(['python3',str(script),str(root),'1','backup_daily_*.tar*'],capture_output=True,text=True)
            self.assertEqual(p.returncode,0,p.stderr)
            self.assertFalse((root/'backup_daily_old.tar').exists());self.assertFalse((root/'backup_daily_delta.tar.sha256').exists())
            self.assertTrue((root/'backup_daily_new.tar').exists())
            (root/'backup_daily_new.tar.parent').write_text('../escape\n')
            p=subprocess.run(['python3',str(script),str(root),'0','*'],capture_output=True,text=True)
            self.assertEqual(p.returncode,1);self.assertTrue((root/'backup_daily_new.tar').exists())

    def deploy_probe(self, code):
        with tempfile.TemporaryDirectory(prefix='enos-deploy-test-') as td:
            env=os.environ|{'DEPLOY_ROOT':td+'/deploy','BACKUP_DIR':td+'/backup','LOG_DIR':td+'/log','RUN_DIR':td+'/run','LOG_TO_FILE':'false'}
            p=subprocess.run(['bash','-c','source '+shlex.quote(str(PROJECTS/'deployer/deployer.sh'))+'; '+code],env=env,capture_output=True,text=True,timeout=5)
            self.assertEqual(p.returncode,0,p.stderr)

    def test_deployer_stops_after_service_failure(self):
        self.deploy_probe('SERVICES=(first second); CONTAINERS=(container); MANIFESTS=(manifest); STRATEGY=in-place; ROLLBACK_ON_FAILURE=false; calls=(); run_hook(){ return 0; }; notify_deployment_result(){ return 0; }; deploy_service(){ calls+=("service:$1"); return 1; }; deploy_container(){ calls+=(container); }; deploy_from_manifest(){ calls+=(manifest); }; if do_deploy; then exit 8; fi; [[ "${calls[*]}" == service:first ]]')

    def test_deployer_canary_metrics_fail_closed(self):
        self.deploy_probe('CANARY_STAGES="5 100"; CANARY_OBSERVE_TIME=0; calls=(); deploy_service(){ return 0; }; set_canary_weight(){ calls+=("$1"); }; if deploy_canary app; then exit 8; fi; [[ "${calls[*]}" == "5 0" ]]')

    def test_deployer_parent_owned_temporary_cleanup(self):
        self.deploy_probe('initialise_temp_workspace; f=$(make_temp_file); d=$(make_temp_dir); [[ -f "$f" && -d "$d" ]]; cleanup_on_exit; [[ ! -e "$f" && ! -e "$d" ]]')

    def test_monitor_first_alert_is_complete_json(self):
        with tempfile.TemporaryDirectory(prefix='enos-monitor-test-') as td:
            code='source '+shlex.quote(str(PROJECTS/'monitor/monitor.sh'))+'; get_cpu_usage(){ echo 99; }; get_memory_usage(){ echo 1; }; get_swap_usage(){ echo 0; }; get_all_disk_info(){ echo "/|1|0|1|1"; }; get_load_average(){ echo "0 0 0"; }; get_cpu_cores(){ echo 1; }; init_config -o json --cpu-threshold 80 --mem-threshold 100 --disk-threshold 100; run_checks'
            p=subprocess.run(['bash','-c',code],env=os.environ|{'LOG_DIR':td+'/logs','RUN_DIR':td+'/run'},capture_output=True,text=True,timeout=5)
            self.assertEqual(p.returncode,2,p.stderr)
            data=json.loads(p.stdout);self.assertEqual(data['alerts_count'],1);self.assertEqual(data['metrics']['cpu']['usage'],99)


if __name__ == '__main__':unittest.main()
