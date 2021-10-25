###################################################################
# SecurityGroup bastion
###################################################################


resource "aws_security_group" "bastion" {
    
  vpc_id      = aws_vpc.vpc.id
  name        = "${var.project}-bastion"
  description = "allow 22 port"

  ingress = [
    {
      description      = ""
      prefix_list_ids  = []
      security_groups  = []
      self             = false
      from_port        = 22
      to_port          = 22
      protocol         = "tcp"
      cidr_blocks      = [ "0.0.0.0/0" ]
      ipv6_cidr_blocks = [ "::/0" ]
    } 
      
  ]

  egress = [
    { 
      description      = ""
      prefix_list_ids  = []
      security_groups  = []
      self             = false
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
  ]

  tags = {
    Name = "${var.project}-bastion"
    Project = var.project
  }
}


###################################################################
# SecurityGroup webserver
###################################################################


resource "aws_security_group" "webserver" {
    
  vpc_id      = aws_vpc.vpc.id
  name        = "${var.project}-webserver"
  description = "allow 80,443,22 port"

  ingress = [
    {
      description      = ""
      prefix_list_ids  = []
      security_groups  = []
      self             = false
      from_port        = 80
      to_port          = 80
      protocol         = "tcp"
      cidr_blocks      = [ "0.0.0.0/0" ]
      ipv6_cidr_blocks = [ "::/0" ]
    },
    {
      description      = ""
      prefix_list_ids  = []
      security_groups  = []
      self             = false
      from_port        = 443
      to_port          = 443
      protocol         = "tcp"
      cidr_blocks      = [ "0.0.0.0/0" ]
      ipv6_cidr_blocks = [ "::/0" ]
    },
    {
      description      = ""
      prefix_list_ids  = []
      security_groups  = []
      self             = false
      from_port        = 22
      to_port          = 22
      protocol         = "tcp"
      cidr_blocks      = []
      ipv6_cidr_blocks = []
      security_groups  = [ aws_security_group.bastion.id ]
    }
      
  ]

  egress = [
     { 
      description      = ""
      prefix_list_ids  = []
      security_groups  = []
      self             = false
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
  ]

  tags = {
    Name = "${var.project}-webserver"
    Project = var.project
  }
}


###################################################################
# SecurityGroup database
###################################################################


resource "aws_security_group" "database" {
    
  vpc_id      = aws_vpc.vpc.id
  name        = "${var.project}-database"
  description = "allow 3306,22 port"

  ingress = [
    
    {
      description      = ""
      prefix_list_ids  = []
      security_groups  = []
      self             = false
      from_port        = 22
      to_port          = 22
      protocol         = "tcp"
      cidr_blocks      = []
      ipv6_cidr_blocks = []
      security_groups  = [ aws_security_group.bastion.id ]
    },
    {
      description      = ""
      prefix_list_ids  = []
      security_groups  = []
      self             = false
      from_port        = 3306
      to_port          = 3306
      protocol         = "tcp"
      cidr_blocks      = []
      ipv6_cidr_blocks = []
      security_groups  = [ aws_security_group.webserver.id ]
    }
      
  ]

  egress = [
     { 
      description      = ""
      prefix_list_ids  = []
      security_groups  = []
      self             = false
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
  ]

  tags = {
    Name = "${var.project}-database"
    Project = var.project
  }
}


