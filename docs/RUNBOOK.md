# Operations Runbook

## Daily Checks

1. Open AWS Backup console.
2. Confirm the latest backup jobs completed successfully.
3. Review failed or expired jobs.
4. Verify recovery points are created in the expected vault.
5. Check SNS or email notifications for failures.

## CLI Commands

List recent backup jobs:

```bash
aws backup list-backup-jobs --by-backup-vault-name <vault-name>
```

List recovery points:

```bash
aws backup list-recovery-points-by-backup-vault \
  --backup-vault-name <vault-name>
```

Export backup jobs for reporting:

```bash
mkdir -p reports
aws backup list-backup-jobs --by-backup-vault-name <vault-name> > reports/backup-jobs.json
python scripts/generate_backup_summary.py --input reports/backup-jobs.json
```

## Backup Failure Triage

| Symptom | Possible Cause | Action |
|---|---|---|
| Backup job failed | IAM role permission issue | Check AWSBackupServiceRolePolicyForBackup attachment |
| No resources selected | Missing EC2 tag | Confirm `BackupPlan=daily-backup` exists on the instance |
| KMS access issue | KMS key policy or region issue | Confirm the vault uses the correct KMS key |
| Cross-region copy failed | DR vault or KMS issue | Check secondary region vault and key configuration |
| Email alert not received | SNS subscription not confirmed | Confirm the email subscription |

## Restore Testing

Recommended monthly test:

1. Select a recent recovery point.
2. Restore to a sandbox subnet or isolated account.
3. Validate instance boot, volume attachment, and application-level checks.
4. Record restore time and issues found.
5. Update RTO/RPO documentation.

## Emergency Rollback

If a Terraform change breaks backup coverage:

1. Stop additional destructive changes.
2. Re-run `terraform plan` with the last known working variables.
3. Confirm backup plan, vault, IAM role, and selection are present.
4. Reapply only after reviewing drift and failed jobs.
5. Manually trigger an on-demand backup for critical instances if needed.
