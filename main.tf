terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

variable "AWS_SECRET_KEY" {
  description = "The AWS secret key"
  type        = string
  sensitive   = true
}

variable "AWS_ACCESS_KEY" {
  description = "The AWS Access key"
  type        = string
  sensitive   = true
}

# Define the AWS provider
provider "aws" {
  region = "us-east-1"
  # access_key = var.AWS_ACCESS_KEY
  # secret_key = var.AWS_SECRET_KEY
}

module "db" {
  source = "terraform-aws-modules/rds/aws"

  identifier = "demodb"

  engine            = "mysql"
  engine_version    = "5.7"
  instance_class    = "db.t3a.large"
  allocated_storage = 5

  db_name  = "demodb"
  username = "user"
  password = "your-password" # Ensure to use a secure way to manage passwords, such as AWS Secrets Manager
  port     = "3306"

  iam_database_authentication_enabled = true

  vpc_security_group_ids = ["sg-12345678"]

  maintenance_window = "Mon:00:00-Mon:03:00"
  backup_window      = "03:00-06:00"

  # Enhanced Monitoring
  monitoring_interval    = "30"
  monitoring_role_name   = "MyRDSMonitoringRole"
  create_monitoring_role = true

  tags = {
    Owner       = "user"
    Environment = "dev"
  }

  # DB subnet group
  create_db_subnet_group = true
  subnet_ids             = ["subnet-12345678", "subnet-87654321"]

  # DB parameter group
  family = "mysql5.7"

  # DB option group
  major_engine_version = "5.7"

  # Database Deletion Protection
  deletion_protection = true

  # Enable storage encryption
  #storage_encrypted = true
  #kms_key_id        = "your-kms-key-id" # Ensure to replace this with your actual KMS key ID

  # Backup settings
  backup_retention_period = 7 # Retain backups for 7 days
  copy_tags_to_snapshot   = true

  # Ensure the database is not publicly accessible
  publicly_accessible = false

  parameters = [
    {
      name  = "character_set_client"
      value = "utf8mb4"
    },
    {
      name  = "character_set_server"
      value = "utf8mb4"
    }
  ]

  options = [
    {
      option_name = "MARIADB_AUDIT_PLUGIN"

      option_settings = [
        {
          name  = "SERVER_AUDIT_EVENTS"
          value = "CONNECT"
        },
        {
          name  = "SERVER_AUDIT_FILE_ROTATIONS"
          value = "37"
        },
      ]
    },
  ]
}
