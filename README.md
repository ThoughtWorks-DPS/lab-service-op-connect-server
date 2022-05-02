# op-connect-server



- assumes existing platform-vpc
- exec dps.nic.cheneweth -- terraform plan -var-file=environments/sandbox.json -var="op_credentials_file_base64=${OP_CREDENTIAL_FILE_BASE64}"