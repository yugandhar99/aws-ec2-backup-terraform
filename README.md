# AWS EC2 Backup Automation with Terraform

A production-style AWS Backup solution for protecting EC2 instances using Terraform, tag-based backup selection, KMS encryption, optional SNS alerts, optional cross-region backup copy, GitHub Actions quality checks, drift detection, and an optional GenAI-style backup operations summary.

This project is designed as a Cloud / DevOps / Infrastructure as Code portfolio project. It shows how backup automation can be managed through AWS-native services instead of custom snapshot scripts.

## Project Highlights

- AWS Backup plan for EC2 instance protection
- Tag-based EC2 backup selection using `BackupPlan=daily-backup`
- Encrypted backup vault using AWS KMS
- Optional cross-region backup copy for disaster recovery
- Optional AWS Backup Vault Lock configuration
- Optional SNS notifications for backup and restore job status
- Terraform variable validation and environment tfvars
- GitHub Actions for Terraform format, validation, TFLint, and Checkov scanning
- Manual drift-detection workflow for deployed infrastructure
- Optional sample EC2 instances disabled by default to avoid surprise AWS charges
- Optional GenAI/Bedrock backup summary helper for operations reporting

## Architecture

```text
EC2 Instances with BackupPlan=daily-backup tag
        |
        v
AWS Backup Selection
        |
        v
AWS Backup Plan ---- schedule / lifecycle / retention
        |
        v
Encrypted Backup Vault using KMS
        |
        +--> SNS notifications for backup and restore events
        |
        +--> Optional cross-region copy to DR backup vault
        |
        +--> Optional Backup Vault Lock governance/compliance control
```

## Technology Stack

| Area | Tools / Services |
|---|---|
| Cloud | AWS Backup, EC2, EBS, KMS, SNS, IAM |
| IaC | Terraform |
| Security | KMS encryption, IAM service role, Backup Vault Lock, Checkov |
| CI/CD | GitHub Actions |
| Quality | terraform fmt, terraform validate, TFLint |
| DR | Optional cross-region backup copy |
| GenAI / Ops | Optional Amazon Bedrock backup summary helper |

## Repository Structure

```text
.
├── main.tf                         # AWS Backup, IAM, KMS, SNS, optional EC2 resources
├── variables.tf                    # Input variables and validation
├── outputs.tf                      # Useful Terraform outputs
├── versions.tf                     # Terraform and provider versions
├── locals.tf                       # Common tags and naming values
├── envs/
│   ├── dev.tfvars                  # Dev values
│   └── prod.tfvars                 # Prod-style values
├── .github/workflows/
│   ├── cicd.yaml                   # Terraform quality checks
│   └── drift.yaml                  # Manual drift detection workflow
├── scripts/
│   └── generate_backup_summary.py  # Optional GenAI-ready backup summary helper
├── docs/
│   ├── ARCHITECTURE.md
│   ├── RUNBOOK.md
│   ├── GENAI_ENHANCEMENT.md
│   └── SCREENSHOTS.md
├── examples/
│   └── backup-jobs.sample.json
├── SECURITY.md
├── PORTFOLIO_NOTES.md
└── GITHUB_UPLOAD_STEPS.md
```

## Prerequisites

- AWS account with permissions for AWS Backup, EC2, KMS, IAM, SNS, and Terraform state backend resources
- Terraform `>= 1.6.0`
- AWS CLI configured locally or use AWS CloudShell
- Optional: TFLint, Checkov, pre-commit

## Quick Start

### 1. Clone the repository

```bash
git clone <your-repo-url>
cd aws-ec2-backup-terraform
```

### 2. Review environment variables

Update `envs/dev.tfvars` or create your own file:

```hcl
project_name             = "aws-ec2-backup-terraform"
environment              = "dev"
aws_region               = "us-west-2"
backup_schedule          = "cron(0 2 * * ? *)"
retention_days           = 14
enable_sns_notifications = true
notification_email       = ""
```

### 3. Initialize and validate

```bash
terraform fmt -recursive
terraform init
terraform validate
```

### 4. Plan

```bash
terraform plan -var-file=envs/dev.tfvars
```

### 5. Apply

```bash
terraform apply -var-file=envs/dev.tfvars
```

## How to Back Up EC2 Instances

The backup plan selects EC2 instances by tag. Add this tag to any EC2 instance you want protected:

```text
Key: BackupPlan
Value: daily-backup
```

You can change the tag key/value using:

```hcl
backup_tag_key   = "BackupPlan"
backup_tag_value = "daily-backup"
```

## Optional Features

### Cross-Region Copy

Enable this in `prod.tfvars` when you want disaster recovery backup copies in a secondary region:

```hcl
enable_cross_region_copy    = true
dr_region                   = "us-east-1"
cross_region_retention_days = 90
```

### SNS Email Notifications

Set an email address. AWS will send a subscription confirmation email that must be accepted.

```hcl
enable_sns_notifications = true
notification_email       = "your-email@example.com"
```

### Backup Vault Lock

For stronger governance, enable Backup Vault Lock carefully. Test in a sandbox first.

```hcl
enable_vault_lock              = true
vault_lock_min_retention_days  = 7
vault_lock_max_retention_days  = 365
vault_lock_changeable_for_days = null
```

### Optional Demo EC2 Instances

This is disabled by default to avoid surprise costs.

```hcl
create_example_ec2_instances = true
```

The demo creates three sample EC2 instances. Two have the backup tag and one intentionally does not, so you can demonstrate tag-based selection.

## GitHub Actions

The repo includes two workflows:

1. `Terraform Quality Checks`
   - Terraform format check
   - Terraform init without backend
   - Terraform validate
   - TFLint
   - Checkov IaC security scan

2. `Terraform Drift Detection`
   - Manual workflow to run Terraform plan against deployed state
   - Opens or updates a GitHub issue if drift is detected

## Optional GenAI Backup Summary

Export backup job data:

```bash
mkdir -p reports
aws backup list-backup-jobs --by-backup-vault-name <vault-name> > reports/backup-jobs.json
```

Generate an offline summary:

```bash
python scripts/generate_backup_summary.py \
  --input reports/backup-jobs.json \
  --output reports/backup-summary.md
```

Optional Amazon Bedrock mode:

```bash
python scripts/generate_backup_summary.py \
  --input reports/backup-jobs.json \
  --output reports/backup-summary.md \
  --bedrock
```

## Testing the Helper Script

```bash
python scripts/generate_backup_summary.py \
  --input examples/backup-jobs.sample.json \
  --output reports/sample-backup-summary.md
```

## Cleanup

```bash
terraform destroy -var-file=envs/dev.tfvars
```

Important: review backup vault recovery points before destroying. In real environments, backup deletion should follow the company retention and compliance process.

## Interview Talking Point

I built an AWS Backup automation project using Terraform to protect EC2 workloads through tag-based backup selection. The solution includes an encrypted backup vault, IAM service role, lifecycle retention, optional cross-region copy, SNS notifications, Vault Lock, GitHub Actions validation, drift detection, and an optional GenAI summary helper for backup operations reporting.

## Future Improvements

- Add AWS Backup Audit Manager framework examples
- Add AWS Organizations backup policy example
- Add centralized reporting dashboard with CloudWatch metrics
- Add restore automation workflow for DR testing
- Add Open Policy Agent or Conftest policy-as-code checks
- Add Cost Explorer reporting for backup storage trends
