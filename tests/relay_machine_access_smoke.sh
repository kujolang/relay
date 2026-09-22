#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
KUJO="${KUJO:-${KUJO_BIN:-$ROOT/../kujo/target/release/kujo}}"
python3 - "$ROOT" "$KUJO" <<'PY'
import concurrent.futures,copy,hashlib,json,os,pathlib,subprocess,sys,tempfile,time
root,kujo=sys.argv[1:]
with tempfile.TemporaryDirectory(prefix='relay-machine-v2-') as temp:
 base=pathlib.Path(temp).resolve(); state=base/'state'; policy_file=base/'policy.json'
 secret='fixture-identity-secret-1234'; expiry=int(time.time()*1000)+240000
 policy={'contract_version':'relay-machine-policy-v2','identities':{'reader':{'role':'reader','tenant':'one','secret_sha256':hashlib.sha256(secret.encode()).hexdigest(),'actions':['runs.read.list','runs.cancel']},'operator':{'role':'operator','tenant':'one','secret_sha256':hashlib.sha256(b'fixture-operator-secret-1234').hexdigest(),'actions':['runs.cancel']}},'resources':{'run-one':'one','run-two':'two'},'approvals':[]}
 def save(p=policy):policy_file.write_text(json.dumps(p))
 save()
 env={**os.environ,'RELAY_ROOT':root,'RELAY_STATE_ROOT':str(state),'RELAY_MACHINE_ACCESS_ENABLED':'true','RELAY_MACHINE_POLICY_PATH':str(policy_file),'RELAY_MACHINE_REQUEST_SECRET':secret}
 count=0
 def request(**updates):
  global count
  count+=1
  return {'contract_version':'relay-machine-request-v2','identity':'reader','tenant':'one','action':'runs.read.list','resource':'run-one','request_id':f'req-{count}','expires_at_ms':expiry,**updates}
 def call(req, extra=None):
  result=subprocess.run([kujo,'run',root+'/main.kujo','--','machine','authorize','--json'],env={**env,'RELAY_MACHINE_REQUEST':json.dumps(req),**(extra or {})},text=True,capture_output=True,timeout=20)
  try:value=json.loads(result.stdout)
  except Exception:raise AssertionError((result.returncode,result.stdout,result.stderr))
  assert (result.returncode==0)==value['ok'],value
  return value
 def denied(req,extra=None):
  value=call(req,extra);assert not value['ok'],value;return value
 good=request();good_result=call(good);assert good_result['authorized'];assert 'replay' in denied(good)['error']
 for changes in [{'contract_version':'relay-machine-request-v1'},{'role':'operator'},{'approval':True},{'tenant':'two'},{'resource':'run-two'},{'resource':'unknown'},{'action':'runs.read.arbitrary'},{'action':'unknown.delete.all'},{'action':'runs.cancel'},{'identity':'operator'},{'identity':'missing'},{'expires_at_ms':0},{'expires_at_ms':expiry+600000},{'expires_at_ms':str(expiry)},{'expires_at_ms':True},{'request_id':'../escape'}]:denied(request(**changes))
 denied(request(),{'RELAY_MACHINE_REQUEST_SECRET':'incorrect-secret-value'})
 denied(request(),{'RELAY_MACHINE_ACCESS_ENABLED':'false'})
 denied(request(),{'RELAY_MACHINE_POLICY_PATH':'','RELAY_MACHINE_ACCESS_SECRET':secret})
 mutation=request(identity='operator',action='runs.cancel');policy['approvals']=[copy.deepcopy(mutation)];save()
 op_env={'RELAY_MACHINE_REQUEST_SECRET':'fixture-operator-secret-1234'}
 assert call(mutation,op_env)['audit']['approval']
 denied(mutation,op_env)
 for changes in [{'resource':'run-two'},{'tenant':'two'},{'request_id':'stolen-approval'},{'expires_at_ms':expiry+1}]:denied({**mutation,**changes},{**op_env,'RELAY_STATE_ROOT':str(base/('approval-mismatch-'+str(len(str(changes)))))})
 # Strict policy validation and fail-closed configuration.
 for bad in [{},[],{**policy,'contract_version':'relay-machine-policy-v1'},{**policy,'approvals':[{'identity':'operator'}]},{**policy,'identities':{'reader':{**policy['identities']['reader'],'actions':['runs.read.*']}}}]:
  save(bad);denied(request())
 policy_file.write_text('{');denied(request())
 policy_file.write_text('x'*65537);denied(request());save()
 # Rotation changes credentials without deleting replay evidence.
 rotated='fixture-rotated-secret-1234';policy['identities']['reader']['secret_sha256']=hashlib.sha256(rotated.encode()).hexdigest();save()
 denied(request());assert call(request(),{'RELAY_MACHINE_REQUEST_SECRET':rotated})['ok'];denied(good,{'RELAY_MACHINE_REQUEST_SECRET':rotated})
 env['RELAY_MACHINE_REQUEST_SECRET']=rotated
 duplicate=request()
 with concurrent.futures.ThreadPoolExecutor(max_workers=2) as pool: results=list(pool.map(lambda _:call(duplicate),range(2)))
 assert sum(r['ok'] for r in results)==1,results
 denied(duplicate)
 # Corruption, capacity, unsafe paths and held locks never admit a request.
 audit=state/'machine-audit-v2.jsonl';backup=audit.read_text()
 audit.write_text(backup[:-1]);denied(request())
 audit.write_text('{bad}\n');denied(request())
 audit.write_text('x'*1048577);denied(request());audit.write_text(backup)
 lock=state/'machine-access.lock';lock.mkdir();denied(request());lock.rmdir()
 audit.unlink();audit.symlink_to(base/'outside');denied(request());assert not (base/'outside').exists();audit.unlink();audit.write_text(backup)
 link=base/'policy-link';link.symlink_to(policy_file);denied(request(),{'RELAY_MACHINE_POLICY_PATH':str(link)})
 state_link=base/'state-link';state_link.symlink_to(state,target_is_directory=True);denied(request(),{'RELAY_STATE_ROOT':str(state_link)})
 rows=[json.loads(line) for line in audit.read_text().splitlines()]
 assert len({(r['identity'],r['request_id']) for r in rows})==len(rows)
 assert all(r['contract_version']=='relay-machine-access-v2' for r in rows)
 assert secret not in audit.read_text() and rotated not in audit.read_text()
 assert call(request())['ok']
 for name,value in [('machine-policy-v2',policy),('machine-request-v2',good),('machine-access-v2',good_result)]:
  fixture=base/(name+'.json');fixture.write_text(json.dumps(value))
  subprocess.run([sys.executable,root+'/scripts/validate_json.py',root+'/schemas/'+name+'.schema.json',str(fixture)],check=True)
 print('PASS operator-owned identities, resources, roles, exact actions, approvals, expiry, replay and durable audit safety')
PY
