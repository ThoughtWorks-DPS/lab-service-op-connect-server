data "aws_secretsmanager_secret" "op_connect_credentials_file" {
  name = "${var.connect_credential_secret_name}"
}
