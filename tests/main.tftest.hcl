# Terraform native tests for the AWS EC2 Backup project.

run "validate_backup_plan" {
  command = plan

  assert {
    condition     = aws_backup_plan.main.rule[0].rule_name == "daily_ec2_backup_rule"
    error_message = "Backup plan rule name should be daily_ec2_backup_rule."
  }

  assert {
    condition     = aws_backup_plan.main.rule[0].lifecycle[0].delete_after == var.retention_days
    error_message = "Primary backup retention should match retention_days."
  }
}

run "validate_backup_selection" {
  command = plan

  assert {
    condition     = aws_backup_selection.ec2_backup.selection_tag[0].key == var.backup_tag_key
    error_message = "Backup selection tag key should match backup_tag_key."
  }

  assert {
    condition     = aws_backup_selection.ec2_backup.selection_tag[0].value == var.backup_tag_value
    error_message = "Backup selection tag value should match backup_tag_value."
  }
}

run "validate_security_controls" {
  command = plan

  assert {
    condition     = aws_backup_vault.main.kms_key_arn == aws_kms_key.backup.arn
    error_message = "Backup vault should use the project KMS key."
  }

  assert {
    condition     = aws_kms_key.backup.enable_key_rotation == true
    error_message = "KMS key rotation should be enabled."
  }
}
