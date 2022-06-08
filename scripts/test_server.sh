#!/usr/bin/env bash
export INSTANCE=$1
export VAULT=$2

if [[ "${INSTANCE}" == "test" ]]; then
  export OP_CONNECT_HOST=https://test.op.twdps.io
  export OP_CONNECT_TOKEN=${TEST_OP_CONNECT_TOKEN}
fi

cat <<EOF > integration_test.tpl
{{ op://${VAULT}/integration-test/key }}
EOF

op inject -i integration_test.tpl -o integration_test.env
cat integration_test.env | grep twdps
