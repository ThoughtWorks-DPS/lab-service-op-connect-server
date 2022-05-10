# op-connect-server

So far, tested two different deployment configurations - from examples in [Connect](https://github.com/1Password/connect) repo   
1. ECS Fargate based on [example](example.yaml)  
1. minikube. Following the dps local dev environment configuration  

Have not been able to get either to work. The ECS method times out with no logged errors (useful or otherwise), and the local version returns a 404 for any uri.  

To deploy the kubernetes version you need a secretes.yaml in the following format:

```
apiVersion: v1
kind: Secret
metadata:
  name: credentials
  namespace: op-connect-local
type: Opaque
data:
  1password-credentials.json: <contents of 1password.credentials.json in base64>
```

# development

- assumes no secrets bootstrap service, just circleci context ENV vars
- assumes use of existing platform-vpc
- assumes a base64 version of the 1password-credential.json for the server is available in the ENV
- aws-vault exec dps.nic.cheneweth -- terraform plan -var-file=environments/sandbox.json -var="op_credentials_file_base64=${OP_CREDENTIAL_FILE_BASE64}"
