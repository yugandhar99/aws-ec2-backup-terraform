locals {
  project_name = var.project_name

  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
    Owner       = var.owner
  }

  protected_resource_arns = [
    "arn:aws:ec2:*:*:instance/*"
  ]

  example_instances = {
    backup-a = "daily-backup"
    backup-b = "daily-backup"
    no-backup = "no-backup"
  }
}
