provider "aws" {
  region = "us-east-2"
}

resource "aws_instance" "app1" {
  ami	= "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
  key_name = "appuser"
  tags = {
    Name = "terraform-example"
  }
  user_data = <<-EOF
	      #!/bin/bash
              echo "Hello, World" > index.html
              nohup busybox httpd -f -p 8080 &
              EOF
  vpc_security_group_ids = [aws_security_group.instance.id]
}

resource "aws_security_group" "instance" {
  name = "terraform-example-instance"

  ingress {
    from_port	= 8080
    to_port	= 8080
    protocol	= "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "busybox http server"
  }
}


resource "aws_key_pair" "appuser" {
  key_name   = "appuser"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDX8ik3cnM4WOvAW27LqbYisCtRWAkYKxW0JFMwcNJJHJiTUHyB93oNkwjM+UBvMgMO2W43O7w5AO8z/19N2GfTINFwMgDsj45OtXj97BHZmKB0XRpkdV7r8B7V6GU5L6yJsIdkglfPiPxda8ivVqBobKW5jIZqPfvQCT2mRSuoCZLpAeC8XcK7Rj8/WW+OM74PLkY6uK0kIhdCgy6TeXX/3FL+rg+bjIwas39fa5yo+3BTfvBMzO/Z5t8uyYJaRZzuR6vkxolfWGZNgiyYsyTQj66/OCu8nacxQdQd5du4uMlw4zqzMChAwR2jl/w7uzigmRaEBWBUZ+sSg1xsgvpR appuser"
  }
