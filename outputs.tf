output "backup_plan_id" {
  description = "ID of the AWS Backup plan."
  value       = aws_backup_plan.main.id
}

output "backup_vault_name" {
  description = "Name of the primary AWS Backup vault."
  value       = aws_backup_vault.main.name
}

output "backup_vault_arn" {
  description = "ARN of the primary AWS Backup vault."
  value       = aws_backup_vault.main.arn
}

output "dr_backup_vault_arn" {
  description = "ARN of the DR backup vault when cross-region copy is enabled."
  value       = var.enable_cross_region_copy ? aws_backup_vault.dr[0].arn : null
}

output "kms_key_arn" {
  description = "ARN of the KMS key used for primary backup vault encryption."
  value       = aws_kms_key.backup.arn
}

output "backup_selection_tag" {
  description = "Tag key/value used by AWS Backup to select EC2 instances."
  value = {
    key   = var.backup_tag_key
    value = var.backup_tag_value
  }
}

output "sns_topic_arn" {
  description = "SNS topic ARN for backup notifications when enabled."
  value       = var.enable_sns_notifications ? aws_sns_topic.backup_notifications[0].arn : null
}

output "example_ec2_instances" {
  description = "Optional sample EC2 instances created for demonstration."
  value = {
    for name, instance in aws_instance.example : name => {
      instance_id = instance.id
      backup_tag  = instance.tags[var.backup_tag_key]
    }
  }
}
