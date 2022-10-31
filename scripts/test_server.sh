#!/usr/bin/env bash
set -o pipefail

export INSTANCE=$1
export VAULT=$2

if [[ "${INSTANCE}" == "test" ]]; then
  export OP_CONNECT_HOST=https://test.op.twdps.io
  export OP_CONNECT_TOKEN=${TEST_OP_CONNECT_TOKEN}
fi

if [[ "${INSTANCE}" == "cohorts" ]]; then
  export OP_CONNECT_HOST=https://cohort.op.twdps.io
  export OP_CONNECT_TOKEN=${COHORT_OP_CONNECT_TOKEN}
fi

cat <<EOF > integration_test.tpl
{{ op://${VAULT}/op-integration-test/key }}
EOF

op inject -i integration_test.tpl -o integration_test.env
cat integration_test.env | grep twdps
