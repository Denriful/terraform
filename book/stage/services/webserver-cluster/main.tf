#variable "server_port" {
#  description = "HTTP server port"
#  type = number
#  default = 8080
#}

#output "public_ip" {
#  value		= aws_instance.example.public_ip
#  description	= "Public IP of instance"
#}

#output "alb_dns_name" {
#  value		= aws_lb.example.dns_name
#  description	= "The domain name of the load balancer"
#}

provider "aws" {
  region = "us-east-2"
}

#resource "aws_instance" "example" {
#  ami	= "ami-0c55b159cbfafe1f0"
#  instance_type = "t2.micro"
#  key_name = "appuser"
#  tags = {
#    Name = "terraform-example"
resource "aws_launch_configuration" "example" {
  image_id	= "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
  key_name = "appuser"
  #user_data = <<-EOF
	      #!/bin/bash
  #            echo "Hello, World" > index.html
  #            echo "${data.terraform_remote_state.db.outputs.address}" >> index.html
  #            echo "${data.terraform_remote_state.db.outputs.port}" >> index.html
  #            nohup busybox httpd -f -p ${var.server_port} &
  #            EOF

  user_data = data.template_file.user_data.rendered

#  vpc_security_group_ids = [aws_security_group.instance.id]
  security_groups = [aws_security_group.instance.id]
}

data "template_file" "user_data" {
  template      = file("user-data.sh")

  vars          = {
    server_port = var.server_port
    db_address  = data.terraform_remote_state.db.outputs.address
    db_port     = data.terraform_remote_state.db.outputs.port
  }
}



# Define ASG
resource "aws_autoscaling_group" "example" {

  launch_configuration = aws_launch_configuration.example.name

  # lets insert vpc subnet ids from data source to ASG  

  vpc_zone_identifier = data.aws_subnet_ids.default.ids

  # Aim Target Group of ALB to ASG instances
  # this will tell the ASG to register each instance 
  # in the Target group when that instance is booting.

  target_group_arns = [aws_lb_target_group.asg-tg.arn]

  # Define Health Check "ELB" instead of default "EC2"
  # Health Check "ELB" more advanced and robust

  health_check_type = "ELB"

  
  min_size = 2
  max_size = 10

  tag {
    key		= "Name"
    value	= "terraform-asg-example"
    propagate_at_launch = true
    }
}


# add data source to query provider for VPC Subnets ID's

data "aws_vpc" "default" {
# filter query for "default" vpc
  default = true
}

data "aws_subnet_ids" "default" {
# filter query for default vpc id
vpc_id = data.aws_vpc.default.id
}

# add ALB (Application Load Balancer (for HTTP HTTPS traffic))

resource "aws_lb" "example" {
  name			= "terraform-asg-example-lb"
  load_balancer_type	= "application"
  subnets		= data.aws_subnet_ids.default.ids
  security_groups	= [aws_security_group.alb_sg.id]

}

# define a listener for ALB

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.example.arn
  port		    = 80
  protocol          = "HTTP"

  # By default, return a simple 404 page
  
  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "404: page not found"
      status_code  = 404
    }
  }
}


# define a listener rule for ALB

resource "aws_lb_listener_rule" "asg" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 100

  condition {
    field  = "path-pattern"
    values = ["*"]
  }

  action {
    type		= "forward"
    target_group_arn	= aws_lb_target_group.asg-tg.arn
  }
}


# add Security Group for ALB

resource "aws_security_group" "alb_sg" {
  name = "terraform-example-alb-sg"

  # Allow inbound HTTP requests
  ingress {
    from_port	= 80
    to_port	= 80
    protocol	= "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound requests
  egress {
    from_port	= 0
    to_port	= 0
    protocol	= "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


# Define Target Group for ALB

resource "aws_lb_target_group" "asg-tg" {
  name		= "terraform-asg-tg-example"
  port		= var.server_port
  protocol	= "HTTP"
  vpc_id	= data.aws_vpc.default.id

  health_check {
    path		= "/"
    protocol		= "HTTP"
    matcher		= "200"
    interval		= 15
    timeout		= 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}


resource "aws_security_group" "instance" {
  name = "terraform-example-instance"

  ingress {
    from_port	= var.server_port
    to_port	= var.server_port
    protocol	= "tcp"
    cidr_blocks = ["0.0.0.0/0"]
# this is best practice
#    cidr_blocks = ["amazon-elb/amazon-elb-sg"]
    description = "busybox http server"
  }
}


resource "aws_key_pair" "appuser" {
  key_name   = "appuser"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDX8ik3cnM4WOvAW27LqbYisCtRWAkYKxW0JFMwcNJJHJiTUHyB93oNkwjM+UBvMgMO2W43O7w5AO8z/19N2GfTINFwMgDsj45OtXj97BHZmKB0XRpkdV7r8B7V6GU5L6yJsIdkglfPiPxda8ivVqBobKW5jIZqPfvQCT2mRSuoCZLpAeC8XcK7Rj8/WW+OM74PLkY6uK0kIhdCgy6TeXX/3FL+rg+bjIwas39fa5yo+3BTfvBMzO/Z5t8uyYJaRZzuR6vkxolfWGZNgiyYsyTQj66/OCu8nacxQdQd5du4uMlw4zqzMChAwR2jl/w7uzigmRaEBWBUZ+sSg1xsgvpR appuser"
  }

terraform {
   backend "s3" {
      bucket         = "terraform-up-and-running-state-denriful"
      key            = "stage/service/webserver-cluster/terraform.tfstate"
      region         = "us-east-2"
      dynamodb_table = "terraform-up-and-running-locks"
      encrypt        = true
   }
}

# These resources already defined in /stage/services/mysql

# resource "aws_s3_bucket" "terraform_state" {
#    bucket = "terraform-up-and-running-state-denriful"

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

# resource "aws_dynamodb_table" "terraform_locks" {
#    name           = "terraform-up-and-running-locks"
#    billing_mode   = "PAY_PER_REQUEST"
#    hash_key       = "LockID"

#    attribute {
#       name = "LockID"
#       type = "S"
#    }
# }

data "terraform_remote_state" "db" {
  backend = "s3"

  config = {
    bucket = "terraform-up-and-running-state-denriful"
    key    = "stage/data-stores/mysql/terraform.tfstate"
    region = "us-east-2"
  }
}

