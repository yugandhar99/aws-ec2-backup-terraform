# GenAI Enhancement

## Purpose

This project includes an optional GenAI-style operations helper that turns AWS Backup job data into a readable backup summary. This is useful for DevOps, SRE, and Cloud Operations teams because backup jobs can be noisy and manual review takes time.

## What It Does

The helper script can summarize:

- Total backup jobs reviewed
- Backup job status count
- Resource type count
- Failed or abnormal backup jobs
- Suggested next actions

## Offline Mode

Offline mode does not require any AI service. It only reads a local JSON export from AWS Backup.

```bash
aws backup list-backup-jobs --by-backup-vault-name <vault-name> > reports/backup-jobs.json
python scripts/generate_backup_summary.py --input reports/backup-jobs.json
```

## Optional Amazon Bedrock Mode

Bedrock mode can rewrite the offline summary into a more executive-friendly release-risk style report.

```bash
python scripts/generate_backup_summary.py \
  --input reports/backup-jobs.json \
  --output reports/backup-summary.md \
  --bedrock
```

## Why This Is Market-Relevant

Many teams are using AI-assisted operations for release notes, incident summaries, change-risk summaries, backup reporting, and compliance evidence preparation. This feature keeps the project practical: it does not put secrets in code and it still works without AI.

## Safe Usage Notes

- Do not send sensitive resource names, account IDs, or customer data to external AI services unless approved.
- Prefer Amazon Bedrock inside the AWS account for enterprise-controlled usage.
- Keep offline mode as the default for GitHub portfolio demonstration.
