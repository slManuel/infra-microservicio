import hashlib
import json
from pathlib import Path
import tempfile
import unittest
from approved_plan import validate_plan, validate_source

class ApprovalTests(unittest.TestCase):
    def test_successful_main_and_reject_untrusted_or_stale_source(self):
        run={'status':'completed','conclusion':'success','workflow_id':7,'head_branch':'develop','event':'push','head_sha':'a'*40}
        validate_source(run,7,'a'*40,'a'*40,'develop')
        for key,value in [('conclusion','failure'),('workflow_id',8),('head_branch','feature'),('event','pull_request'),('head_sha','b'*40)]:
            with self.subTest(key=key), self.assertRaises(ValueError):
                validate_source(dict(run,**{key:value}),7,'a'*40,'a'*40,'develop')
        with self.assertRaises(ValueError):validate_source(run,7,'a'*40,'b'*40,'develop')

    def test_exact_plan_and_reject_tampered_bytes_or_metadata(self):
        with tempfile.TemporaryDirectory() as temp:
            root=Path(temp);plan=root/'infra.tfplan';plan.write_bytes(b'approved plan fixture')
            digest=hashlib.sha256(plan.read_bytes()).hexdigest()
            metadata={'run_id':'123','run_attempt':'1','commit':'a'*40,'sha256':digest,'environment':'development','state_key':'microservicio/development/terraform.tfstate','state_bucket':'tfstate-prueba-cuscatlan-oct2026-jose-manuel-solis','branch':'develop'}
            path=root/'plan-metadata.json';path.write_text(json.dumps(metadata))
            validate_plan(root,'123',1,'a'*40,digest,'development')
            with self.assertRaises(ValueError):
                validate_plan(root,'123',1,'a'*40,digest,'qa')
            with self.assertRaises(ValueError):
                validate_plan(root,'123',1,'a'*40,digest,'production')
            path.write_text(json.dumps(dict(metadata,state_key='microservicio/qa/terraform.tfstate')))
            with self.assertRaises(ValueError):
                validate_plan(root,'123',1,'a'*40,digest,'development')
            path.write_text(json.dumps(dict(metadata,state_bucket='tfstate-prueba-cuscatlan-oct2026-jose-manuel-solis-qa')))
            with self.assertRaises(ValueError):
                validate_plan(root,'123',1,'a'*40,digest,'development')
            path.write_text(json.dumps(metadata))
            plan.write_bytes(b'different plan')
            with self.assertRaises(ValueError):validate_plan(root,'123',1,'a'*40,digest,'development')
            plan.write_bytes(b'approved plan fixture')
            path.write_text(json.dumps(dict(metadata,run_attempt='2')))
            with self.assertRaises(ValueError):validate_plan(root,'123',1,'a'*40,digest,'development')

if __name__=='__main__':unittest.main()
