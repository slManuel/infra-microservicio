#!/usr/bin/env python3
"""Bind a manual approval to one successful branch workflow and exact saved plan."""
import hashlib
import json
import os
from pathlib import Path
import re
import subprocess
import sys

def gh_json(path):
    return json.loads(subprocess.check_output(['gh', 'api', path], text=True))

def validate_source(run, workflow_id, commit, branch_commit, branch):
    if not (run['status'] == 'completed' and run['conclusion'] == 'success'
            and run['workflow_id'] == workflow_id and run['head_branch'] == branch and branch in ('develop','qa','main')
            and run['event'] in ('push', 'workflow_dispatch')
            and run['head_sha'] == commit == branch_commit):
        raise ValueError('Plan must be a successful trusted branch run at the current approved commit')

def state_bucket(environment):
    suffix = {'development':'', 'qa':'-qa', 'production':'-production'}[environment]
    return 'tfstate-prueba-cuscatlan-oct2026-jose-manuel-solis' + suffix

def validate_plan(directory, run_id, attempt, commit, digest, environment):
    metadata = json.loads((directory/'plan-metadata.json').read_text())
    actual = hashlib.sha256((directory/'infra.tfplan').read_bytes()).hexdigest()
    expected = {'run_id':str(run_id), 'run_attempt':str(attempt), 'commit':commit, 'sha256':digest, 'environment':environment,
                'state_key':f'microservicio/{environment}/terraform.tfstate',
                'state_bucket':state_bucket(environment),
                'branch':{'development':'develop','qa':'qa','production':'main'}[environment]}
    if metadata != expected or actual != digest:
        raise ValueError('Approved plan metadata or SHA-256 does not match')

def selected_environment():
    environment = os.environ['TARGET_ENVIRONMENT']
    if environment not in ('development', 'qa', 'production'):
        raise ValueError('Unknown target environment')
    branch = {'development':'develop','qa':'qa','production':'main'}[environment]
    if os.environ['GITHUB_REF'] != 'refs/heads/' + branch:
        raise ValueError('Selected environment does not match the workflow branch')
    directory = Path.cwd()
    if directory.name != environment or directory.parent.name != 'environments':
        raise ValueError('Terraform working directory must match selected environment')
    return environment

def record():
    environment = selected_environment()
    metadata = {'run_id':os.environ['GITHUB_RUN_ID'],
                'run_attempt':os.environ['GITHUB_RUN_ATTEMPT'],
                'commit':os.environ['GITHUB_SHA'],
                'sha256':hashlib.sha256(Path('infra.tfplan').read_bytes()).hexdigest(),
                'environment':environment,
                'state_key':f'microservicio/{environment}/terraform.tfstate',
                'state_bucket':state_bucket(environment),
                'branch':{'development':'develop','qa':'qa','production':'main'}[environment]}
    Path('plan-metadata.json').write_text(json.dumps(metadata, indent=2)+'\n')
    with open(os.environ['GITHUB_STEP_SUMMARY'], 'a') as summary:
        summary.write('\nManual approval requires these exact values:\n\n```json\n'+json.dumps(metadata,indent=2)+'\n```\n')
    print(json.dumps(metadata))

def fetch():
    environment = selected_environment()
    run_id = os.environ['APPROVED_RUN_ID']
    commit = os.environ['APPROVED_COMMIT']
    digest = os.environ['APPROVED_SHA256']
    if not (re.fullmatch(r'[1-9][0-9]*',run_id) and re.fullmatch(r'[0-9a-f]{40}',commit)
            and re.fullmatch(r'[0-9a-f]{64}',digest)):
        raise ValueError('Expected numeric plan run ID, full commit and lowercase SHA-256')
    branch = {'development':'develop','qa':'qa','production':'main'}[environment]
    repo = os.environ['GITHUB_REPOSITORY']
    run = gh_json(f'repos/{repo}/actions/runs/{run_id}')
    workflow = gh_json(f'repos/{repo}/actions/workflows/terraform.yml')
    head = gh_json(f'repos/{repo}/git/ref/heads/{branch}')['object']['sha']
    validate_source(run, workflow['id'], commit, head, branch)
    if commit != os.environ['GITHUB_SHA']:
        raise ValueError('Dispatch commit differs from approved plan; request a fresh plan')
    directory = Path('.approved-plan')
    directory.mkdir(mode=0o700)
    subprocess.run(['gh','run','download',run_id,'--repo',repo,'--name',
                    f'terraform-plan-{environment}-{run_id}-{run["run_attempt"]}','--dir',str(directory)],check=True)
    validate_plan(directory, run_id, run['run_attempt'], commit, digest, environment)
    print('Approved plan source, current branch commit and SHA-256, environment and state key verified. No re-plan.')

if __name__ == '__main__':
    {'record':record,'fetch':fetch}[sys.argv[1]]()
