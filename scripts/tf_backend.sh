#!/usr/bin/env bash

cat <<EOF >  ~/.terraformrc
credentials "app.terraform.io" {
  token = "${TFE_TOKEN}"
}
EOF