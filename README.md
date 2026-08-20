☁️ Local DevSecOps Cloud Platform: AWS & Terraform Simulation

📌 Project Overview

This repository demonstrates a complete, production-grade cloud infrastructure deployment using Infrastructure as Code (IaC) entirely within a localized, zero-cost environment.

The core objective of this portfolio project is to showcase secure AWS architecture design, including isolated VPC boundaries, least-privilege IAM policies, encrypted storage, and dynamic secret injection, all orchestrated via Terraform and emulated locally via LocalStack and Docker.

⚙️ Architecture & Tech Stack

Infrastructure as Code: Terraform (configured to target local endpoints)

Cloud Provider Emulation: LocalStack (localhost:4566)

Secrets Management: HashiCorp Vault (Local Dev Server)

Database Tier: PostgreSQL (Simulating AWS RDS)

Containerization: Docker & Docker Compose

CLI Tooling: awscli-local (awslocal wrapper)

🗺️ Project Roadmap & Completed Tasks

[x] Phase 1 (Network): Containerize LocalStack and deploy a VPC with isolated Public and Private subnets.

[x] Phase 2 (Identity): Implement IAM Roles with strict Least Privilege trust and resource-bound permission policies.

[x] Phase 3 (Storage): Provision an S3 bucket with forced AES256 encryption at rest and Public Access Blocks.

[x] Phase 3.5 (Security): Deploy stateful Security Groups chaining ingress rules to simulate database network boundaries.

[x] Phase 4 (Vault): Spin up HashiCorp Vault via Docker Compose for dynamic, centralized secrets management.

[x] Phase 4.5 (Integration): Configure Terraform to fetch Vault secrets dynamically and inject them securely into AWS Secrets Manager.

[x] Phase 5 (OpSec): Implement a strict .gitignore to prevent Terraform state files (.tfstate) and plaintext environment tokens from leaking.

🚨 Security Controls & Architecture Decisions

Cloud Domain

Security Principle

Implementation Strategy

VPC & Networking

Blast Radius Reduction

Segregated public and private subnets. Resources without a need for internet ingress are strictly localized.

IAM (Identity)

Least Privilege

Avoided * wildcards. Scoped GetSecretValue and S3 actions strictly to exact resource ARNs and specific environment prefixes.

S3 (Storage)

Secure by Default

Applied aws_s3_bucket_public_access_block to prevent accidental data exposure and enforced Server-Side Encryption (SSE).

Security Groups

Zero Trust Lateral Movement

Database ingress is not open to the VPC CIDR; it explicitly requires the connecting instance to hold the Application Security Group ID.

Secrets Management

No Hardcoded Credentials

Database passwords are stored in HashiCorp Vault, pulled dynamically by Terraform at runtime, and injected into AWS Secrets Manager.

🔄 The Infrastructure Deployment Workflow

The platform is defined in the docker-compose.yml and terraform/ directory and executes as follows:

Environment Bootstrapping: Docker Compose launches LocalStack, HashiCorp Vault, and PostgreSQL on isolated local ports.

Secret Seeding: Database credentials are manually seeded into Vault's local Key-Value store to simulate a mature enterprise secrets engine.

Terraform Initialization: The HashiCorp AWS and Vault providers are initialized, overriding default AWS API endpoints to point to localhost:4566.

Infrastructure Provisioning: terraform apply builds the VPC, routing tables, S3 buckets, and IAM roles, dynamically pulling the Postgres password from Vault and injecting it into AWS Secrets Manager as a JSON payload.

🚀 How to Run Locally

Prerequisites

Docker & Docker Compose

Terraform (1.5+)

Python 3 & pip (for awscli-local)

Environment Setup

# 1. Clone the repository
git clone https://github.com/pinheiro2/local-devsecops-cloud.git
cd local-devsecops-cloud

# 2. Setup isolated Python environment and install LocalStack wrapper
python3 -m venv .venv
source .venv/bin/activate
pip install awscli-local

# 3. Create your LocalStack authentication environment file
echo "LOCALSTACK_AUTH_TOKEN=ls-your-token-here" > .env


Launching the Stack

# 1. Start the Docker containers (LocalStack, Vault, Postgres)
sudo docker compose up -d

# 2. Seed Vault with the database credentials
sudo docker exec -e VAULT_ADDR="http://127.0.0.1:8200" devsecops_vault vault kv put secret/devsecops-lab/db-creds \
  username="admin" \
  password="supersecret_bootstrap_password" \
  engine="postgres" \
  host="devsecops_db" \
  port=5432 \
  dbname="appdb"

# 3. Provision the infrastructure
cd terraform
terraform init
terraform apply -auto-approve


Verifying the Deployment

# Verify the VPC & Subnets
awslocal ec2 describe-vpcs --region eu-west-1
awslocal ec2 describe-subnets --region eu-west-1 --query "Subnets[*].{ID:SubnetId, CIDR:CidrBlock}"

# Verify S3 Public Access Blocks
awslocal s3api get-public-access-block --bucket devsecops-lab-app-data

# Retrieve the dynamically injected AWS Secret
awslocal secretsmanager get-secret-value \
  --secret-id devsecops-lab-db-credentials \
  --region eu-west-1 \
  --query "SecretString" \
  --output text
