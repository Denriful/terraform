provider "aws" {
  region = "us-east-2"
}

module "webserver_cluster" {
  
  source = "../../../modules/services/webserver-cluster"

  cluster_name            = "webservers-stage"

  db_remote_state_bucket  = "terraform-up-and-running-state-denriful"

  db_remote_state_key     = "stage/data-stores/mysql/terraform.tfstate"

  instance_type           = "t2.micro"

  min_size                = 2

  max_size                = 5

  server_port             = 8081

  server_port2            = 22

  enable_autoscaling      = false
  }

resource "aws_security_group_rule" "allow_testing_inbound" {
  type              = "ingress"
  security_group_id = module.webserver_cluster.alb_security_group_id

  from_port	  = 22
  to_port	    = 22
  protocol	  = "tcp"
  cidr_blocks = ["0.0.0.0/0"] 
}

terraform {
    backend "s3" {
       bucket         = "terraform-up-and-running-state-denriful"
       key            = "stage/services/webserver-cluster/terraform.tfstate"
       region         = "us-east-2"
       dynamodb_table = "terraform-up-and-running-locks"
       encrypt        = true
    }
 }


# S3 Bucket and Dynamo-DB allready must be created by mysql main.tf

#resource "aws_s3_bucket" "terraform_state" {
#    bucket = "terraform-up-and-running-state-denriful"

    # Prevent accidental deletion of this S3 bucket
#    lifecycle {
#       prevent_destroy = true
#    }

#    # Enable versioning so we can see the full
#    # revision history of our state files
#    versioning {
#       enabled = true
 #   }

#    # Enable server-side encryption by default
#    server_side_encryption_configuration {
#       rule {
#          apply_server_side_encryption_by_default {
#             sse_algorithm = "AES256"
#          }
#      }
#   }
#}
# }

#resource "aws_dynamodb_table" "terraform_locks" {
#     name           = "terraform-up-and-running-locks"
#     billing_mode   = "PAY_PER_REQUEST"
#     hash_key       = "LockID"

#     attribute {
#        name = "LockID"
#       type = "S"
#     }
#}
