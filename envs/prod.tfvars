project_name                 = "aws-ec2-backup-terraform"
environment                  = "prod"
owner                        = "platform-team"
aws_region                   = "us-west-2"
dr_region                    = "us-east-1"
backup_schedule              = "cron(0 2 * * ? *)"
retention_days               = 35
cold_storage_after_days      = null
enable_sns_notifications     = true
notification_email           = ""
create_example_ec2_instances = false
enable_cross_region_copy     = true
cross_region_retention_days  = 90
enable_vault_lock            = false

