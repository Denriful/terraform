provider "aws" {
   region = "us-east-2"
}

terraform {
   backend "s3" {
     bucket         = "terraform-up-and-running-state-denriful"
     key            = "global/s3/terraform.tfstate"
     region         = "us-east-2"
     dynamodb_table = "terraform-up-and-running-locks"
     encrypt        = true
  }
}

resource "aws_s3_bucket" "terraform_state" {
   bucket = "terraform-up-and-running-state-denriful"

   # Prevent accidental deletion of this S3 bucket
   lifecycle {
      prevent_destroy = true
   }

   # Enable versioning so we can see the full
   # revision history of our state files
   versioning {
      enabled = true
   }

   # Enable server-side encryption by default
   server_side_encryption_configuration {
      rule {
         apply_server_side_encryption_by_default {
           sse_algorithm = "AES256"
         }
      }
   }
 }


resource "aws_dynamodb_table" "terraform_locks" {
   name           = "terraform-up-and-running-locks"
   billing_mode   = "PAY_PER_REQUEST"
   hash_key       = "LockID"

   attribute {
      name = "LockID"
      type = "S"
   }
}

# to connect to instance you also need to open port 22
resource "aws_key_pair" "appuser" {
  key_name   = "appuser"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDX8ik3cnM4WOvAW27LqbYisCtRWAkYKxW0JFMwcNJJHJiTUHyB93oNkwjM+UBvMgMO2W43O7w5AO8z/19N2GfTINFwMgDsj45OtXj97BHZmKB0XRpkdV7r8B7V6GU5L6yJsIdkglfPiPxda8ivVqBobKW5jIZqPfvQCT2mRSuoCZLpAeC8XcK7Rj8/WW+OM74PLkY6uK0kIhdCgy6TeXX/3FL+rg+bjIwas39fa5yo+3BTfvBMzO/Z5t8uyYJaRZzuR6vkxolfWGZNgiyYsyTQj66/OCu8nacxQdQd5du4uMlw4zqzMChAwR2jl/w7uzigmRaEBWBUZ+sSg1xsgvpR appuser"
}