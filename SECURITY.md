# Security Notes

## Secret Handling

- Do not commit AWS access keys, secret keys, Terraform state files, `.env` files, or real tfvars files containing sensitive data.
- Use GitHub Actions secrets or OIDC-based AWS authentication for CI/CD.
- Use an S3 backend with DynamoDB locking for team usage.

## Backup Security Controls

- Backup vault encryption is enabled using AWS KMS.
- EC2 root volumes for optional sample instances are encrypted.
- EC2 metadata service is configured with IMDSv2 for optional sample instances.
- AWS Backup uses a service role with AWS managed backup/restore policies.
- Optional Backup Vault Lock can add retention governance.

## Recommended Production Improvements

- Use GitHub OIDC instead of long-lived AWS keys.
- Add SCPs or IAM boundaries to prevent unauthorized backup deletion.
- Add AWS Backup Audit Manager for compliance evidence.
- Test restore regularly and document restore results.
