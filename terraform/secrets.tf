# 1. Fetch the secret from Vault dynamically
data "vault_generic_secret" "db_creds" {
  path = "secret/devsecops-lab/db-creds"
}

# 2. Define the AWS Secret container
resource "aws_secretsmanager_secret" "db_creds" {
  name                    = "${var.environment}-db-credentials"
  description             = "Database connection string and credentials"
  recovery_window_in_days = 0 
}

# 3. Inject the Vault payload into AWS Secrets Manager
resource "aws_secretsmanager_secret_version" "db_creds_version" {
  secret_id     = aws_secretsmanager_secret.db_creds.id
  
  # Pass the entire data payload from Vault directly into AWS
  secret_string = jsonencode(data.vault_generic_secret.db_creds.data)
}