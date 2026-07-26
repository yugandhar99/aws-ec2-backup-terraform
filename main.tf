# -----------------------------------------------------------------------------
# Optional demo EC2 instances
# -----------------------------------------------------------------------------
# These resources are disabled by default to avoid accidental AWS charges.
# Enable create_example_ec2_instances=true only in a sandbox account.

data "aws_vpc" "d efault" {
  count   = var.create_example_ec2_instances ? 1 : 0
  default = true
}

data "aws_subnets" "default" {
  count = var.create_example_ec2_instances ? 1 : 0

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default[0].id]
  }
}

data "aws_ami" "amazon_linux" {
  count       = var.create_example_ec2_instances ? 1 : 0
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "example" {
  for_each = var.create_example_ec2_instances ? local.example_instances : {}

  ami           = data.aws_ami.amazon_linux[0].id
  instance_type = var.example_instance_type
  subnet_id     = data.aws_subnets.default[0].ids[0]
  monitoring    = true

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  root_block_device {
    encrypted   = true
    volume_type = "gp3"
    volume_size = 8
  }

  tags = {
    Name                 = "${local.project_name}-${each.key}-${var.environment}"
    (var.backup_tag_key) = each.value
  }
}

# -----------------------------------------------------------------------------
# KMS keys
# -----------------------------------------------------------------------------

resource "aws_kms_key" "backup" {
  description             = "KMS key for ${local.project_name} AWS Backup vault in ${var.environment}"
  deletion_window_in_days = 7
  enable_key_rotation     = true
}

resource "aws_kms_alias" "backup" {
  name          = "alias/${local.project_name}-backup-${var.environment}"
  target_key_id = aws_kms_key.backup.key_id
}

resource "aws_kms_key" "backup_dr" {
  count = var.enable_cross_region_copy ? 1 : 0

  provider                = aws.dr
  description             = "DR KMS key for ${local.project_name} AWS Backup vault in ${var.environment}"
  deletion_window_in_days = 7
  enable_key_rotation     = true
}

resource "aws_kms_alias" "backup_dr" {
  count = var.enable_cross_region_copy ? 1 : 0

  provider      = aws.dr
  name          = "alias/${local.project_name}-backup-dr-${var.environment}"
  target_key_id = aws_kms_key.backup_dr[0].key_id
}

# -----------------------------------------------------------------------------
# AWS Backup IAM role
# -----------------------------------------------------------------------------

resource "aws_iam_role" "backup_role" {
  name = "${local.project_name}-backup-role-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "backup.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "backup_policy" {
  role       = aws_iam_role.backup_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
}

resource "aws_iam_role_policy_attachment" "restore_policy" {
  role       = aws_iam_role.backup_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForRestores"
}

# -----------------------------------------------------------------------------
# AWS Backup vaults, vault lock, notifications, and plan
# -----------------------------------------------------------------------------

resource "aws_backup_vault" "main" {
  name        = "${local.project_name}-vault-${var.environment}"
  kms_key_arn = aws_kms_key.backup.arn
}

resource "aws_backup_vault" "dr" {
  count = var.enable_cross_region_copy ? 1 : 0

  provider    = aws.dr
  name        = "${local.project_name}-dr-vault-${var.environment}"
  kms_key_arn = aws_kms_key.backup_dr[0].arn
}

resource "aws_backup_vault_lock_configuration" "main" {
  count = var.enable_vault_lock ? 1 : 0

  backup_vault_name   = aws_backup_vault.main.name
  min_retention_days  = var.vault_lock_min_retention_days
  max_retention_days  = var.vault_lock_max_retention_days
  changeable_for_days = var.vault_lock_changeable_for_days
}

resource "aws_sns_topic" "backup_notifications" {
  count = var.enable_sns_notifications ? 1 : 0

  name              = "${local.project_name}-backup-alerts-${var.environment}"
  kms_master_key_id = "alias/aws/sns"
}


resource "aws_sns_topic_policy" "backup_notifications" {
  count = var.enable_sns_notifications ? 1 : 0

  arn = aws_sns_topic.backup_notifications[0].arn

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowAwsBackupToPublish"
        Effect = "Allow"
        Principal = {
          Service = "backup.amazonaws.com"
        }
        Action   = "sns:Publish"
        Resource = aws_sns_topic.backup_notifications[0].arn
      }
    ]
  })
}

resource "aws_sns_topic_subscription" "email" {
  count = var.enable_sns_notifications && var.notification_email != "" ? 1 : 0

  topic_arn = aws_sns_topic.backup_notifications[0].arn
  protocol  = "email"
  endpoint  = var.notification_email
}

resource "aws_backup_vault_notifications" "main" {
  count = var.enable_sns_notifications ? 1 : 0

  backup_vault_name   = aws_backup_vault.main.name
  sns_topic_arn       = aws_sns_topic.backup_notifications[0].arn
  backup_vault_events = ["BACKUP_JOB_COMPLETED", "BACKUP_JOB_FAILED", "RESTORE_JOB_COMPLETED", "RESTORE_JOB_FAILED"]

  depends_on = [aws_sns_topic_policy.backup_notifications]
}

resource "aws_backup_plan" "main" {
  name = "${local.project_name}-plan-${var.environment}"

  rule {
    rule_name         = "daily_ec2_backup_rule"
    target_vault_name = aws_backup_vault.main.name
    schedule          = var.backup_schedule

    lifecycle {
      cold_storage_after = var.cold_storage_after_days
      delete_after       = var.retention_days
    }

    dynamic "copy_action" {
      for_each = var.enable_cross_region_copy ? [1] : []

      content {
        destination_vault_arn = aws_backup_vault.dr[0].arn

        lifecycle {
          delete_after = var.cross_region_retention_days
        }
      }
    }

    recovery_point_tags = merge(local.common_tags, {
      BackupType = "automated"
      Workload   = "ec2"
    })
  }

  lifecycle {
    precondition {
      condition     = var.cold_storage_after_days == null || var.retention_days >= var.cold_storage_after_days + 90
      error_message = "When cold storage is enabled, AWS Backup retention must be at least cold_storage_after_days + 90 days."
    }
  }
}

resource "aws_backup_selection" "ec2_backup" {
  iam_role_arn = aws_iam_role.backup_role.arn
  name         = "${local.project_name}-ec2-selection-${var.environment}"
  plan_id      = aws_backup_plan.main.id
  resources    = local.protected_resource_arns

  selection_tag {
    type  = "STRINGEQUALS"
    key   = var.backup_tag_key
    value = var.backup_tag_value
  }
}
