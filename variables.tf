variable "project_name" {
  description = "Project name used for resource naming and tagging."
  type        = string
  default     = "aws-ec2-backup-terraform"

  validation {
    condition     = can(regex("^[a-z0-9-]{3,40}$", var.project_name))
    error_message = "project_name must be 3-40 characters and use only lowercase letters, numbers, and hyphens."
  }
}


variable "owner" {
  description = "Owner tag value for cost allocation and accountability."
  type        = string
  default     = "platform-team"
}

variable "environment" {
  description = "Environment name."
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "test", "stage", "prod"], var.environment)
    error_message = "environment must be one of: dev, test, stage, prod."
  }
}

variable "aws_region" {
  description = "Primary AWS region."
  type        = string
  default     = "us-west-2"
}

variable "dr_region" {
  description = "Secondary AWS region used when cross-region copy is enabled."
  type        = string
  default     = "us-east-1"
}

variable "backup_schedule" {
  description = "AWS Backup schedule expression. Example: cron(0 2 * * ? *) for daily backups at 02:00 UTC."
  type        = string
  default     = "cron(0 2 * * ? *)"

  validation {
    condition     = startswith(var.backup_schedule, "cron(") || startswith(var.backup_schedule, "rate(")
    error_message = "backup_schedule must be an AWS cron(...) or rate(...) expression."
  }
}

variable "backup_tag_key" {
  description = "Tag key used to select EC2 instances for backup."
  type        = string
  default     = "BackupPlan"
}

variable "backup_tag_value" {
  description = "Tag value used to select EC2 instances for backup."
  type        = string
  default     = "daily-backup"
}

variable "retention_days" {
  description = "Number of days to keep primary-region recovery points."
  type        = number
  default     = 35

  validation {
    condition     = var.retention_days >= 1 && var.retention_days <= 3650
    error_message = "retention_days must be between 1 and 3650."
  }
}

variable "cold_storage_after_days" {
  description = "Optional number of days before transition to cold storage. Set to null to disable cold storage transition."
  type        = number
  default     = null

  validation {
    condition     = var.cold_storage_after_days == null || var.cold_storage_after_days >= 1
    error_message = "cold_storage_after_days must be null or greater than 0."
  }
}

variable "enable_cross_region_copy" {
  description = "When true, backup recovery points are copied to a secondary region vault for DR."
  type        = bool
  default     = false
}

variable "cross_region_retention_days" {
  description = "Number of days to keep copied recovery points in the DR region."
  type        = number
  default     = 90

  validation {
    condition     = var.cross_region_retention_days >= 1 && var.cross_region_retention_days <= 3650
    error_message = "cross_region_retention_days must be between 1 and 3650."
  }
}

variable "enable_vault_lock" {
  description = "Enables AWS Backup Vault Lock governance mode for stronger protection against accidental or malicious deletion."
  type        = bool
  default     = false
}

variable "vault_lock_min_retention_days" {
  description = "Minimum retention days enforced by Backup Vault Lock."
  type        = number
  default     = 7
}

variable "vault_lock_max_retention_days" {
  description = "Maximum retention days enforced by Backup Vault Lock."
  type        = number
  default     = 365
}

variable "vault_lock_changeable_for_days" {
  description = "Number of days Backup Vault Lock remains changeable before compliance lock. Keep null for governance mode."
  type        = number
  default     = null
}

variable "enable_sns_notifications" {
  description = "Creates SNS notifications for backup job status events."
  type        = bool
  default     = true
}

variable "notification_email" {
  description = "Optional email subscriber for backup notifications. Leave empty to create only the SNS topic."
  type        = string
  default     = ""

  validation {
    condition     = var.notification_email == "" || can(regex("^[^@]+@[^@]+\\.[^@]+$", var.notification_email))
    error_message = "notification_email must be empty or a valid email address."
  }
}

variable "create_example_ec2_instances" {
  description = "Creates three sample EC2 instances to demonstrate tag-based backup selection. Disabled by default to avoid accidental charges."
  type        = bool
  default     = false
}

variable "example_instance_type" {
  description = "Instance type for optional sample EC2 instances."
  type        = string
  default     = "t3.micro"
}
