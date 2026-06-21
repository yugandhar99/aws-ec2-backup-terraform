# GitHub Upload Steps

## Recommended Repo Name

```text
aws-ec2-backup-terraform
```

## Recommended Description

```text
AWS EC2 backup automation using Terraform, AWS Backup, KMS, SNS, cross-region copy, GitHub Actions, drift detection, and optional GenAI backup summaries.
```

## Upload Using GitHub Website

1. Create a new empty GitHub repository.
2. Do not add README, `.gitignore`, or license during repo creation because this project already includes them.
3. Extract the ZIP file locally.
4. Open the extracted folder.
5. Upload files/folders in batches if GitHub says more than 100 files.
6. Commit with this message:

```text
Initial commit - AWS EC2 backup Terraform project
```

## Upload Using Git Commands

```bash
git init
git add .
git commit -m "Initial commit - AWS EC2 backup Terraform project"
git branch -M main
git remote add origin https://github.com/<your-username>/aws-ec2-backup-terraform.git
git push -u origin main
```

## Before Running Terraform

- Review `envs/dev.tfvars`
- Configure AWS CLI or GitHub Actions credentials
- Use a sandbox AWS account first
- Keep `create_example_ec2_instances=false` unless you want demo instances
