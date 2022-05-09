resource "aws_instance" "SP2019Machine" {

  ami           = var.ami
  instance_type = var.Instance
  #count         = 1
  tags = {
    name = "SP2k19_Dev"
  }
}

resource "aws_default_vpc" "default" {

}

data "aws_subnet_ids" "default_subnets" {
  vpc_id = aws_default_vpc.default.id
}

resource "aws_security_group" "SP2019_nsg" {
  name   = "SP2019_nsg"
  vpc_id = aws_default_vpc.default.id
  #vpc_id = var.aws_vpc.id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_security_group" "elb_nsg" {
  name   = "elb_nsg"
  vpc_id = aws_default_vpc.default.id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_elb" "SP2019elb" {
  name               = var.loadbalancer
  instances          = [aws_instance.SP2019Machine.id]
  availability_zones = [var.region]
  security_groups    = [aws_security_group.elb_nsg.id]
  subnets            = data.aws_subnet_ids.default_subnets.ids


  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

}

