# Optional remote backend example.
# For real team usage, create an S3 bucket and DynamoDB lock table first, then uncomment and update values.

# terraform {
#   backend "s3" {
#     bucket         = "your-terraform-state-bucket"
#     key            = "aws-ec2-backup-terraform/terraform.tfstate"
#     region         = "us-west-2"
#     dynamodb_table = "terraform-locks"
#     encrypt        = true
#   }
# }
