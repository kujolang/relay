#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
KUJO="${KUJO:-${KUJO_BIN:-$ROOT/../kujo/target/release/kujo}}"
TMP_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/relay-redaction.XXXXXX")"
TMP_ROOT="$(cd "$TMP_ROOT" && pwd -P)"
trap 'rm -rf "$TMP_ROOT"' EXIT
python3 - "$TMP_ROOT/cases.json" <<'PY'
import json,sys
cases=[
 'password="alpha whitespace omega" diagnostic=preserved',
 'api_key="alpha \\"quoted\\" omega" diagnostic=preserved',
 "secret='alpha \\'quoted\\' omega' diagnostic=preserved",
 'RELAY_SIGNING_KEY = "alpha whitespace omega" diagnostic=preserved',
 'password="alpha truncated omega',
 'password="alpha\nmultiline omega" diagnostic=preserved',
 json.dumps({'api_key':'alpha whitespace omega','safe':'preserved'}),
 json.dumps({'message':'password="alpha \\"quoted\\" omega" diagnostic=preserved'}),
 'log ready\n'+json.dumps({'message':'password="alpha whitespace omega" diagnostic=preserved'})+'\nfinished',
 '{"message":"password=\\"alpha truncated omega',
 json.dumps({'ok':True,'usage':{'completion_tokens':3},'nested':[{'safe':'preserved'}]}),
 '-----BEGIN PUBLIC KEY-----\npublic-body\n-----END PUBLIC KEY-----',
 'before\n-----BEGIN PRIVATE KEY-----\nalpha-private-omega\n-----END PRIVATE KEY-----\n'+json.dumps({'safe':'preserved'})
]
cases += ['{\n "message": "password=\\"alpha\n omega', 'log ready\n{\n "message": "password=\\"alpha\n omega']
deep={'message':'password="alpha omega"'}
for _ in range(70): deep={'nested':deep}
cases.append(json.dumps(deep))
cases.append('password="alpha\nmultiline omega" diagnostic=preserved\n'+json.dumps({'safe':'preserved'}))
json.dump(cases,open(sys.argv[1],'w'))
PY
RELAY_REDACTION_CASES="$TMP_ROOT/cases.json" "$KUJO" run "$ROOT/tests/relay_redaction_fixture.kujo" --interpreter > "$TMP_ROOT/results.json"
python3 - "$TMP_ROOT" <<'PY'
import json,pathlib,sys
root=pathlib.Path(sys.argv[1]);cases=json.loads((root/'cases.json').read_text());results=json.loads((root/'results.json').read_text())
assert len(results)==len(cases)
for i,text in enumerate(results):
 assert 'alpha' not in text and 'omega' not in text, (i,text)
 if i in [0,1,2,3,5,6,7,8,10,12]: assert 'preserved' in text,(i,text)
assert 'preserved' in results[16]
for i in [6,7,10]:json.loads(results[i])
assert json.loads(results[10])==json.loads(cases[10])
assert results[11]==cases[11]
assert 'log ready' in results[8] and 'finished' in results[8]
assert 'REDACTED_INVALID_JSON' in results[9]
assert 'REDACTED_INVALID_JSON' in results[13] and 'REDACTED_INVALID_JSON' in results[14]
assert results[14].startswith('log ready')
assert any(marker in results[15] for marker in ['REDACTED_DEPTH_LIMIT','REDACTED_INVALID_JSON']), results[15]
PY
export KUJO_BIN="$KUJO" RELAY_ROOT="$ROOT" RELAY_STATE_ROOT="$TMP_ROOT/state"
export RELAY_AI_BRIDGE="$ROOT/tests/relay_redaction_bridge_fixture.kujo"
"$KUJO" run "$ROOT/main.kujo" -- chat redaction --fixture --json > "$TMP_ROOT/response.json"
"$KUJO" run "$ROOT/main.kujo" -- chat redaction --fixture --stream --json > "$TMP_ROOT/stream.jsonl"
python3 - "$TMP_ROOT" <<'PY'
import json,pathlib,sys
root=pathlib.Path(sys.argv[1]);raw=(root/'response.json').read_text();stream=(root/'stream.jsonl').read_text()
for text in [raw,stream]:
 for forbidden in ['relay-quoted-','credential alpha',' beta','relay-argument-','credential with spaces']:
  assert forbidden not in text, (forbidden,text)
 assert 'diagnostic=preserved' in text
response=json.loads(raw);assert response['ok']
events=response['raw']['stream_events'];assert len(events)==3
assert all(e['id']=='fixture-stream' for e in events)
joined=''.join(e['choices'][0]['delta']['tool_calls'][0]['function']['arguments'] for e in events)
assert json.loads(joined)=={'api_key':'[REDACTED_CREDENTIAL]','safe':True}
rows=[json.loads(line) for line in stream.splitlines()]
assert sum(r['type']=='done' for r in rows)==1
assert rows[-1]['usage']['total_tokens']==5
assert any(r['type']=='delta' and 'preserved' in r['content'] for r in rows)
PY
echo 'PASS quoted, escaped, multiline, truncated and buffered stream credential redaction'
