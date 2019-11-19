provider "aws" {
  region = "us-east-2"
}

resource "aws_db_instance" "example-prod" {
  identifier_prefix = "terraform-up-and-running"
  engine            = "mysql"
  allocated_storage = 10
  instance_class    = "db.t2.micro"
  name              = "example_database_prod"
  username          = "admin"

  # skip snapshot is needed then destroy db 
  # with command:
  # terraform destroy -target=aws_db_instance.example-prod -lock=false
  
  skip_final_snapshot = true
  

  # How should we set the password?
  
  #1. via variables.tf and console command
  # export TF_VAR_db_password="password"
  password          = var.db_password
  
  #2. via Secrets Manager service
  #password          = data.aws_secretsmanager_secret_version.db_password.secret_string  
  
  #3. via Key Management Service
  #password          = data.aws_kms_secret.mysql_password.db_user
}

#data "aws_secretsmanager_secret_version" "db_password" {
#      secret_id = "mysql-master-password-stage1"
#  }

#data "aws_kms_secret" "mysql_password" {
#  secret {
#    name    = "db_user"

     # to acquire payload execute this:
     # echo -n 'password' > /tmp/plaintext-password
     # aws kms encrypt --key-id fdbde304-574e-4ed5-8f83-179873479f90 --plaintext fileb:///tmp/plaintext-password --encryption-context mysql=password --output text --query CiphertextBlob --region us-east-2
#    payload = "AQICAHiqdzdCp6TVMk+LoffOunUtIhx+KZcBKwSJ8UMBm71HNQHafE13CTKItrQKCGim0pDtAAAAZjBkBgkqhkiG9w0BBwagVzBVAgEAMFAGCSqGSIb3DQEHATAeBglghkgBZQMEAS4wEQQMYUkMV50idfLs6RueAgEQgCOLFQV6yrhBUO27GSCBOUVCZkwEnQsFVrxIpApkCuGS7j4Cbg=="

#    context {
#      mysql = "password"
#    }
#  }
#}

# These resources already defined in /global/s3/

 terraform {
    backend "s3" {
       bucket         = "terraform-up-and-running-state-denriful"
       key            = "prod/data-stores/mysql/terraform.tfstate"
       region         = "us-east-2"
       dynamodb_table = "terraform-up-and-running-locks"
       encrypt        = true
    }
 }

 #resource "aws_s3_bucket" "terraform_state" {
 #   bucket = "terraform-up-and-running-state-denriful"

#    # Prevent accidental deletion of this S3 bucket
 #   lifecycle {
 #      prevent_destroy = true
 #   }

#    # Enable versioning so we can see the full
#    # revision history of our state files
 #   versioning {
 #      enabled = true
 #   }

#    # Enable server-side encryption by default
 #   server_side_encryption_configuration {
 #      rule {
 #         apply_server_side_encryption_by_default {
 #           sse_algorithm = "AES256"
 #         }
 #      }
 #   }
 #}
# }

#resource "aws_dynamodb_table" "terraform_locks" {
#    name           = "terraform-up-and-running-locks"
#    billing_mode   = "PAY_PER_REQUEST"
#    hash_key       = "LockID"

#    attribute {
#       name = "LockID"
#       type = "S"
#    }
# }
 