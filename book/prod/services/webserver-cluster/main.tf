provider "aws" {
  region = "us-east-2"
}

module "webserver_cluster" {
  
  source = "../../../modules/services/webserver-cluster"

  cluster_name            = "webservers-prod"

  db_remote_state_bucket  = "terraform-up-and-running-state-denriful"

  db_remote_state_key     = "prod/data-stores/mysql/terraform.tfstate"

  instance_type           = "t2.micro"

  min_size                = 3

  max_size                = 10

  enable_autoscaling      = true

}

/* resource "aws_autoscaling_schedule" "scale_out_during_business_hours" {
  scheduled_action_name  = "scale_out_during_business_hours"
  min_size               = 3
  max_size               = 10
  desired_capacity       = 10
  recurrence             = "0 9 * * *"
  autoscaling_group_name = module.webserver_cluster.asg_name
}

resource "aws_autoscaling_schedule" "scale_in_at_night" {
  scheduled_action_name = "scale_in_at_night"
  min_size              = 2
  max_size              = 10
  desired_capacity      = 2
  recurrence            = "0 17 * * *"
  autoscaling_group_name = module.webserver_cluster.asg_name
} */

terraform {
    backend "s3" {
       bucket         = "terraform-up-and-running-state-denriful"
       key            = "prod/services/webserver-cluster/terraform.tfstate"
       region         = "us-east-2"
       dynamodb_table = "terraform-up-and-running-locks"
       encrypt        = true
    }
 }

# S3 Bucket and Dynamo-DB must be already created by mysql main.tf 

 #resource "aws_s3_bucket" "terraform_state" {
 #   bucket = "terraform-up-and-running-state-denriful"

#    # Prevent accidental deletion of this S3 bucket
#    lifecycle {
#       prevent_destroy = true
#    }

#    # Enable versioning so we can see the full
#    # revision history of our state files
#    versioning {
#       enabled = true
#    }

#    # Enable server-side encryption by default
#    server_side_encryption_configuration {
#       rule {
#          apply_server_side_encryption_by_default {
#             sse_algorithm = "AES256"
#          }
#       }
#    }
# }
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
 