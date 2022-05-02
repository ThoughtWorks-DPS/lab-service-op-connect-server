#!/usr/bin/env bash

# Create a new secret key entry in AWS Secrets Manager if it doesn't already exist.
export INSTANCE=$1
export SECRET_KEYNAME=$2
export AWS_DEFAULT_REGION=$(cat environments/$INSTANCE.json | jq -r .aws_region)
export AWS_ASSUME_ROLE=$(cat environments/$INSTANCE.json | jq -r .aws_assume_role)
export AWS_ACCOUNT_ID=$(cat environments/$INSTANCE.json | jq -r .aws_account_id)

# assumes base credentials are set in the ENV
aws sts assume-role --output json --role-arn arn:aws:iam::$AWS_ACCOUNT_ID:role/$AWS_ASSUME_ROLE --role-session-name op-connect > credentials

export AWS_ACCESS_KEY_ID=$(cat credentials | jq -r ".Credentials.AccessKeyId")
export AWS_SECRET_ACCESS_KEY=$(cat credentials | jq -r ".Credentials.SecretAccessKey")
export AWS_SESSION_TOKEN=$(cat credentials | jq -r ".Credentials.SessionToken")


RESULT=$(aws secretsmanager list-secrets --filter Key="name",Values="${SECRET_KEYNAME}" | grep "${SECRET_KEYNAME}")
if [[ ${RESULT} ]]; then
    echo "Skipping: Secret ${SECRET_KEYNAME} already exists"
else
    echo "Creating secret ${SECRET_KEYNAME}"
    aws secretsmanager create-secret --name ${SECRET_KEYNAME} --description "Secret for ${SECRET_KEYNAME}" --secret-string "create"
fi
