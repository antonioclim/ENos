"""Local semantic fixtures; no institutional keys, service calls or grade policy adoption."""
import ast
import csv
import importlib.util
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest
from unittest import mock

ROOT = Path(__file__).resolve().parents[2]
HERE = ROOT / 'SEM07'

def module(path, name):
    spec = importlib.util.spec_from_file_location(name, path)
    result = importlib.util.module_from_spec(spec)
    sys.modules[name] = result
    spec.loader.exec_module(result)
    return result

class AssessmentContractTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix='enos-assessment-test-')
        self.addCleanup(self.temp.cleanup)
        self.directory = Path(self.temp.name)
        self.verify = module(HERE/'homework_evaluation/verification_engine.py', 'verification_engine')
        self.calc = module(HERE/'grade_aggregation/final_grade_calculator_EN.py', 'enos_calculator_fixture')

    def recording(self, **changes):
        header = {'version':2,'width':80,'height':24,'student_name':'Name Student',
                  'student_group':'1234','seminar':2,'timestamp':1700000000}
        header.update(changes)
        return (json.dumps(header)+'\n[0,"o","text"]\n[1,"m",""]\n[2,"r","100x50"]\n[3,"extension","data"]\n').encode()

    def test_current_recorder_headers_and_legacy_separator(self):
        for directory in ('02_INIT_HOMEWORKS', '03_GUIDES'):
            source = ROOT/directory/'record_homework_tui_EN.py'
            tree = ast.parse(source.read_text())
            fn = next(node for node in tree.body if isinstance(node,ast.FunctionDef) and node.name=='add_recording_metadata')
            namespace = {'Path':Path,'json':json,'os':os,'tempfile':tempfile,'Dict':dict}
            exec(compile(ast.Module(body=[fn],type_ignores=[]),str(source),'exec'),namespace)
            path=self.directory/(directory+'.cast')
            path.write_bytes(b'{"version":2,"width":80,"height":24}\n[0,"o","fixture"]\n')
            namespace['add_recording_metadata'](str(path),{'surname':'Example','firstname':'Student','group':'1234','homework':'02b'})
            with path.open('ab') as out: out.write(b'\n## SIG: legacy-encrypted-payload\n## META: fixture\n')
            row=self.verify.inspect_file(path,self.directory,self.directory/'missing.pem')
            self.assertEqual(row['Seminar'],'SEM02')
            self.assertEqual(row['Metadata_Status'],'COMPLETE')
            self.assertEqual(row['Format_Status'],'VALID')
            self.assertEqual(row['Signature_Status'],'UNVERIFIED')
            self.assertIn('unsupported recorder',row['Reason'])

    def test_format_and_identity_are_separate(self):
        path=self.directory/'malformed.cast'
        path.write_bytes(self.recording()+b'not-json\n')
        row=self.verify.inspect_file(path,self.directory,self.directory/'missing.pem')
        self.assertEqual(row['Format_Status'],'INVALID')
        self.assertEqual(row['Metadata_Status'],'COMPLETE')
        self.assertEqual(row['Signature_Status'],'INVALID')

    def test_version_types_and_event_codes(self):
        for bad in (2.0,True,'2'):
            with self.assertRaises(ValueError): self.verify.parse_header_and_events(self.recording(version=bad))
        header, extensions=self.verify.parse_header_and_events(self.recording())
        self.assertEqual(extensions,['extension'])
        for value in (True,0,'2','UNKNOWN',None): self.assertIsNone(self.verify.seminar_label(value))
        self.assertEqual(self.verify.seminar_label(2),self.verify.seminar_label('SEM02'))

    def test_batch_complete_with_unresolved_records(self):
        (self.directory/'valid.cast').write_bytes(self.recording())
        (self.directory/'bad.cast').write_text('broken\n')
        output=self.directory/'report'
        self.assertEqual(self.verify.main([str(self.directory),'-k',str(self.directory/'missing.pem'),'-o',str(output),'-q']),2)
        with (output/'verification_results.csv').open() as stream: rows=list(csv.DictReader(stream))
        self.assertEqual(len(rows),2)
        self.assertEqual({row['Signature_Status'] for row in rows},{'INVALID','UNVERIFIED'})

    def test_missing_components_remain_none_in_report(self):
        record={'S1':{'name':'Example Student','group':'1234','scores':[],'count':0,'issues':['Unverified homework excluded']}}
        student=self.calc.process_student('S1',record,{}, {})
        self.assertEqual(student.status,'PENDING_POLICY')
        self.assertIsNone(student.homework_average)
        self.assertIsNone(student.project_total)
        self.assertIsNone(student.test_average)
        self.assertIsNone(student.final_grade)
        self.calc.generate_report([student],str(self.directory/'report'))
        with (self.directory/'report.csv').open() as stream: row=next(csv.DictReader(stream))
        self.assertEqual([row[key] for key in ('HW Avg','Project','Test Avg','Weighted Score','Final Grade')],['']*5)
        self.assertIn('Unverified',row['Notes'])
        markdown=(self.directory/'report.md').read_text()
        for absent in ('✗','Grade Distribution','Eliminated (80%','Passing |'):
            self.assertNotIn(absent,markdown)

    def test_reviewed_zero_is_not_missing(self):
        homework={'S1':{'name':'Name','group':'1234','scores':[0.0],'count':1,'issues':[]}}
        project={'S1':{'name':'Name','group':'1234','auto_score':0.0,'manual_score':0.0,'eligible':True}}
        tests={'S1':{'name':'Name','group':'1234','scores':[0.0],'count':1}}
        student=self.calc.process_student('S1',homework,project,tests)
        self.assertEqual((student.homework_average,student.project_total,student.test_average),(0,0,0))
        self.assertEqual(student.status,'PENDING_POLICY')
        self.assertEqual(student.issues,[])

    def policy(self):
        return {'schema_version':1,'score_stage':'final','late_homework_counts':False,
                'weights':{'homework':.25,'project':.5,'tests':.25},
                'thresholds':{'homework_min':1,'homework_total':1,'tests_min':1,'tests_total':1},
                'grade_boundaries':[[5,8],[0,2]],'passing_grade':7,'elimination_grade':None,
                'require_project_eligible':True}

    def test_policy_requires_consequential_choices(self):
        for key in ('passing_grade','elimination_grade','require_project_eligible'):
            policy=self.policy(); policy.pop(key)
            path=self.directory/'policy.json';path.write_text(json.dumps(policy))
            with self.assertRaises(ValueError): self.calc.load_policy(path)
        path=self.directory/'policy.json';path.write_text(json.dumps(self.policy()))
        self.calc.load_policy(path)
        student=self.calc.process_student('S1',{'S1':{'name':'Name','group':'1234','scores':[],'count':0}}, {}, {})
        self.assertEqual(student.status,'PENDING_EVIDENCE')
        self.assertIsNone(student.final_grade)

    def test_explicit_zero_weights_and_optional_project_eligibility(self):
        policy=self.policy()
        policy['weights']={'homework':1.0,'project':0.0,'tests':0.0}
        policy['require_project_eligible']=False
        path=self.directory/'policy.json';path.write_text(json.dumps(policy))
        self.calc.load_policy(path)
        homework={'S1':{'name':'Name','group':'1234','scores':[6.0],'count':1,'issues':[]}}
        student=self.calc.process_student('S1',homework,{}, {})
        self.assertEqual((student.status,student.weighted_score,student.final_grade),('PASS',6.0,8))
        self.assertIsNone(student.project_total)
        self.assertIsNone(student.test_average)
        self.assertIsNone(student.project_eligible)
        self.assertIn('Project eligibility evidence is missing',student.issues)
        self.assertIn('Non-blocking',student.elimination_reason)
        self.calc.generate_report([student],str(self.directory/'zero_weight'))
        with (self.directory/'zero_weight.csv').open() as stream: row=next(csv.DictReader(stream))
        self.assertEqual((row['Project'],row['Test Avg'],row['Weighted Score']),('','','6.00'))
        document=json.loads((self.directory/'zero_weight.json').read_text())
        self.assertEqual(document['policy_status'],'SUPPLIED_POLICY_UNVERIFIED')
        self.assertEqual(document['policy_approval'],'UNVERIFIED')
        self.assertTrue(document['policy_supplied'])
        self.assertEqual(document['students'][0]['final_grade'],8)
        self.assertIsNone(document['students'][0]['project_total'])
        policy['require_project_eligible']=True
        path.write_text(json.dumps(policy));self.calc.load_policy(path)
        pending=self.calc.process_student('S1',homework,{}, {})
        self.assertEqual(pending.status,'PENDING_EVIDENCE')
        self.assertIsNone(pending.final_grade)

    def test_invalid_evidence_and_empty_report(self):
        for value in ('NaN','inf',-1,11,True):
            with self.assertRaises(ValueError):self.calc.checked_number(value,'score')
        self.calc.generate_report([],str(self.directory/'empty'))
        text=(self.directory/'empty.md').read_text()
        self.assertIn('NO_RECORDS',text)
        self.assertNotIn('100%',text)
        with self.assertRaises(ValueError):self.calc.process_student('S1',{}, {}, {})

    def test_json_report_preserves_missing_zero_status_and_reasons(self):
        missing = self.calc.process_student('MISSING',
            {'MISSING':{'name':'Example Missing','group':'DERIVED','scores':[], 'count':0,
                        'issues':['Missing human review']}}, {}, {})
        zero = self.calc.process_student('ZERO',
            {'ZERO':{'name':'Example Zero','group':'DERIVED','scores':[0.0], 'count':1, 'issues':[]}},
            {'ZERO':{'name':'Example Zero','group':'DERIVED','auto_score':0.0,'manual_score':0.0,'eligible':True}},
            {'ZERO':{'name':'Example Zero','group':'DERIVED','scores':[0.0], 'count':1}})
        prefix = self.directory/'json_contract'
        self.calc.generate_report([missing,zero],str(prefix))
        document = json.loads(prefix.with_suffix('.json').read_text())
        self.assertEqual(document['schema_version'],1)
        self.assertEqual(document['policy_status'],'PENDING_POLICY')
        self.assertFalse(document['policy_supplied'])
        rows = {row['student_id']: row for row in document['students']}
        for key in ('homework_average','project_total','test_average','weighted_score','final_grade'):
            self.assertIsNone(rows['MISSING'][key])
        for key in ('homework_average','project_total','test_average'):
            self.assertEqual(rows['ZERO'][key],0.0)
        for row in rows.values():
            self.assertEqual(row['status'],'PENDING_POLICY')
            self.assertIsNone(row['final_grade'])
        self.assertIn('Missing human review',rows['MISSING']['issues'])
        self.assertIn('Missing human review',rows['MISSING']['elimination_reason'])

    def csv_contracts(self):
        return [
            (self.calc.load_homework_grades,
             'student_id,student_name,student_group,seminar,homework_id,final_score,late_days,signature_valid'),
            (self.calc.load_project_grades,
             'student_id,student_name,student_group,auto_score,manual_score,eligible'),
            (self.calc.load_test_grades,
             'student_id,student_name,student_group,test_id,score'),
        ]

    def test_csv_headers_are_required_for_empty_inputs(self):
        path = self.directory/'empty_input.csv'
        for loader,header in self.csv_contracts():
            for invalid in ('', 'unrelated_column\n', header+',\n',header+',student_id\n'):
                with self.subTest(loader=loader.__name__,header=invalid):
                    path.write_text(invalid)
                    with self.assertRaises(ValueError):loader(path)
            path.write_text(header+'\n')
            self.assertEqual(loader(path),{})

    def test_csv_row_width_and_syntax_are_checked(self):
        path = self.directory/'malformed_row.csv'
        for loader,header in self.csv_contracts():
            count = len(header.split(','))
            for invalid in (','.join(['value']*(count-1)), ','.join(['value']*(count+1)), '"unterminated'):
                with self.subTest(loader=loader.__name__,record=invalid):
                    path.write_text(header+'\n'+invalid+'\n')
                    with self.assertRaises(ValueError):loader(path)

    def test_duplicate_score_column_is_rejected_before_selection(self):
        path = self.directory/'duplicate_score.csv'
        path.write_text('student_id,student_name,student_group,seminar,homework_id,final_score,late_days,signature_valid,final_score\n'
                        'DERIVED,Example Student,DERIVED,SEM01,HW01,10,0,true,0\n')
        with self.assertRaisesRegex(ValueError,'duplicate CSV column'):
            self.calc.load_homework_grades(path)

    def test_all_existing_report_destinations_are_preserved(self):
        for index,suffix in enumerate(('.csv','.json','.md')):
            prefix=self.directory/f'existing_{index}'
            target=prefix.with_suffix(suffix)
            target.write_bytes(b'OWNED EXISTING RESULT\n')
            with self.assertRaises(FileExistsError):self.calc.generate_report([],str(prefix))
            self.assertEqual(target.read_bytes(),b'OWNED EXISTING RESULT\n')
            self.assertEqual({p.suffix for p in self.directory.glob(prefix.name+'.*')},{suffix})

    def test_input_aliases_are_preserved_for_every_report_format(self):
        source=self.directory/'owned_input.data'
        source.write_bytes(b'OWNED INPUT OR POLICY\n')
        for index,suffix in enumerate(('.csv','.json','.md')):
            direct=self.directory/f'direct_{index}{suffix}'
            direct.write_bytes(b'OWNED DIRECT INPUT\n')
            with self.assertRaises(ValueError):
                self.calc.generate_report([],str(direct),input_paths=[direct])
            self.assertEqual(direct.read_bytes(),b'OWNED DIRECT INPUT\n')
            for kind in ('symlink','hardlink'):
                with self.subTest(suffix=suffix,kind=kind):
                    target=self.directory/f'{kind}_{index}{suffix}'
                    try:
                        if kind=='symlink':target.symlink_to(source)
                        else:os.link(source,target)
                    except (OSError,NotImplementedError) as error:
                        self.skipTest(f'{kind} is unavailable on this test host: {error}')
                    with self.assertRaises(ValueError):
                        self.calc.generate_report([],str(target),input_paths=[source])
                    self.assertEqual(source.read_bytes(),b'OWNED INPUT OR POLICY\n')
                    self.assertEqual(target.read_bytes(),b'OWNED INPUT OR POLICY\n')

    def test_caught_report_write_failure_cleans_owned_partial_output(self):
        prefix=self.directory/'write_failure'
        original_open=os.open
        def fail_json(path,flags,mode=0o777,**kwargs):
            if Path(path)==prefix.with_suffix('.json'):
                raise OSError('DERIVED controlled output failure')
            return original_open(path,flags,mode,**kwargs)
        with mock.patch.object(self.calc.os,'open',side_effect=fail_json):
            with self.assertRaises(OSError):self.calc.generate_report([],str(prefix))
        self.assertEqual(list(self.directory.glob(prefix.name+'.*')),[])

if __name__ == '__main__': unittest.main()
