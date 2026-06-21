# Architecture

## Goal

The goal of this project is to protect EC2 workloads using AWS Backup and Terraform. Instead of custom Lambda snapshot scripts, the project uses AWS Backup as the managed backup control plane.

## Logical Flow

```text
EC2 instance tagged BackupPlan=daily-backup
        |
        v
AWS Backup Selection
        |
        v
AWS Backup Plan
  - schedule
  - lifecycle retention
  - recovery point tags
        |
        v
Primary AWS Backup Vault
  - KMS encryption
  - optional Vault Lock
  - optional SNS notifications
        |
        v
Optional DR AWS Backup Vault in secondary region
```

## Components

| Component | Purpose |
|---|---|
| AWS Backup Plan | Defines backup schedule, retention, and copy action rules |
| AWS Backup Selection | Selects EC2 resources by tag |
| AWS Backup Vault | Stores backup recovery points |
| KMS Key | Encrypts recovery points at rest |
| IAM Backup Role | Allows AWS Backup to access EC2 and EBS resources |
| SNS Topic | Sends backup and restore job status notifications |
| Backup Vault Lock | Adds governance/compliance controls for recovery point retention |
| GitHub Actions | Validates Terraform code and scans IaC changes |
| Drift Workflow | Detects if deployed infrastructure differs from Terraform code |

## Design Decisions

- Tag-based selection makes onboarding simple: teams only add the required tag to EC2 instances.
- Sample EC2 instances are disabled by default to prevent accidental AWS charges.
- KMS encryption and default tags are enforced through Terraform.
- Cross-region copy is optional because not every workload needs DR-level backup copies.
- Backup Vault Lock is optional because incorrect settings can create long-lived retention behavior.

## Recovery Strategy

Use AWS Backup recovery points to restore EC2 instances or EBS volumes based on the business requirement. Restoration should be tested regularly, because a backup is only useful if it can be restored successfully.
