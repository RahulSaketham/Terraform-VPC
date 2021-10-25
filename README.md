# Creating a VPC using Terraform
Here, I am creating a VPC with 6 subnets(3 public and 3 private) along with an Internet Gateway, a NAT Gateway and 2 Route Tables(1 public and 1 private). Also, a Bastion server(having only SSH access), a webserver(HTTP and HTTPS port enabled and also SSH access from the bastion server) and a database server(with 3306 port and SSH access from bastion server)

## Terraform
Terraform is an open-source infrastructure as code software tool that provides a consistent CLI workflow to manage hundreds of cloud services. Terraform codifies cloud APIs into declarative configuration files.
https://www.terraform.io/

## Installing Terraform
- Create an IAM user on your AWS console and give access to create the required resources.
- Create a directory where you can create terraform configuration files.
- Download Terrafom, click here [Terraform](https://www.terraform.io/downloads.html).
- Install Terraform, click here [Terraform installation](https://learn.hashicorp.com/tutorials/terraform/install-cli?in=terraform/aws-get-started)

##### Command to install Terraform
```sh
# wget https://releases.hashicorp.com/terraform/1.0.8/terraform_1.0.8_linux_amd64.zip
# unzip terraform_1.0.8_linux_amd64.zip
# mv terraform /usr/local/bin/

# terraform version   =======> To check the version
Terraform v1.0.8
on linux_amd64
```

> Note : The terrafom files must be created with .tf extension as terraform can only execute .tf files
> https://www.terraform.io/docs/language/files/index.html

### Terraform commands

#### Terraform Validation
> This will check for any errors on the source code

```sh
terraform validate
```
#### Terraform Plan
> The terraform plan command provides a preview of the actions that Terraform will take in order to configure resources per the configuration file. 

```sh
terraform plan
```
#### Terraform apply
> This will execute the tf file that we created

```sh
terraform apply
```
https://www.terraform.io/docs/cli/commands/index.html

## 1. Declaring Variables
This is used to declare the variable and pass values to terraform source code.
```sh
vim variable.tf
```
##### Declare the variables for initialising terraform

```sh
variable "project" {
  default = "test"
}
variable "access_key"{
  default = " "           #==========> provide the access_key of the IAM user
}
variable "secret_key"{
  default = " "          #==========> provide the secret_key of the IAM user
}
variable "vpc_cidr" {
  default = "172.16.0.0/16"
}
variable "vpc_subnets" {
  default = "3"
}
variable "type" {
  description = "Instance type"    
  default = "t2.micro"
}
variable "ami" {
  description = "amazon linux 2 ami"
  default = "ami-041d6256ed0f2061c"
}
```
##### Creating a variable.tfvars
> Note : A terraform.tfvars file is used to set the actual values of the variables.
```sh
vim variable.tfvars
```
```sh
project     = " Your project name"
access_key  = "IAM user access_key"
secret_key  = "IAM user secret_key"
vpc_cidr    = "VPC cidr block"
```
## 2.  Create the provider file
> Terraform configurations must declare which providers they require, so that Terraform can install and use them. I'm using AWS as provider
```sh
vim provider.tf
```
```sh
provider "aws" {
  region     = "ap-south-1"
  access_key = var.access_key
  secret_key = var.secret_key
}
```

## 3. Fetching Availability Zones in working AWS region
> This will fetch all available Availability Zones in working AWS region and store the details in variable az
```sh
vim az.tf
```
```sh
data "aws_availability_zones" "az" {
  state = "available"
}

output "availability_names" {    
  value = data.aws_availability_zones.az.names
}
```
> I have also added output in this file so that I could get an ouput when I run the command
```sh
terrafrom output
```
https://www.terraform.io/docs/cli/commands/output.html

## 4. Creating VPC
- Create VPC resource
```sh
vim vpc.tf
```
```sh
###################################################################
# Vpc Creation
###################################################################
resource "aws_vpc" "vpc" {
    
  cidr_block            =  var.vpc_cidr
  instance_tenancy      = "default"
  enable_dns_hostnames  = true
  enable_dns_support    = true
  tags = {
    Name = "${var.project}-vpc"
    Project = var.project
  }
    lifecycle {
    create_before_destroy = false
  }
}
```

## 5. Creating and Attaching Internet GateWay
```sh
vim igw.tf
```
```sh
###################################################################
# Attaching Internet GateWay
###################################################################

resource "aws_internet_gateway" "igw" {
    
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${var.project}-igw"
    Project = var.project
  }
    
  lifecycle {
    create_before_destroy = false
  }
}
```

## 6. Creating Public and Private subents
```sh
vim subnet.tf
```
```sh
###################################################################
# Creating Public Subnet1
###################################################################

resource "aws_subnet" "public1" {
    
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = cidrsubnet(var.vpc_cidr,var.vpc_subnets, 0)
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.az.names[0]
  tags = {
    Name = "${var.project}-public1"
    Project = var.project
  }
  lifecycle {
    create_before_destroy = false
  }
}

###################################################################
# Creating Public Subnet2
###################################################################

resource "aws_subnet" "public2" {
    
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = cidrsubnet(var.vpc_cidr,var.vpc_subnets, 1)
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.az.names[1]
  tags = {
    Name = "${var.project}-public2"
    Project = var.project
  }
    
  lifecycle {
    create_before_destroy = false
  }
}

###################################################################
# Creating Public Subnet3
###################################################################

resource "aws_subnet" "public3" {
    
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = cidrsubnet(var.vpc_cidr,var.vpc_subnets,2)
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.az.names[2]
  tags = {
    Name = "${var.project}-public3"
    Project = var.project
  }
  lifecycle {
    create_before_destroy = false
  }
    
}

###################################################################
# Creating Private Subnet1
###################################################################

resource "aws_subnet" "private1" {
    
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = cidrsubnet(var.vpc_cidr,var.vpc_subnets,3)
  map_public_ip_on_launch = false
  availability_zone       = data.aws_availability_zones.az.names[0]
  tags = {
    Name = "${var.project}-private1"
    Project = var.project
  }
  lifecycle {
    create_before_destroy = false
  }
}

###################################################################
# Creating Private Subnet2
###################################################################

resource "aws_subnet" "private2" {
    
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = cidrsubnet(var.vpc_cidr,var.vpc_subnets,4)
  map_public_ip_on_launch = false
  availability_zone       = data.aws_availability_zones.az.names[1]
  tags = {
    Name = "${var.project}-private2"
    Project = var.project
  }
  lifecycle {
    create_before_destroy = false
  }
}

###################################################################
# Creating Private Subnet3
###################################################################
resource "aws_subnet" "private3" {
    
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = cidrsubnet(var.vpc_cidr,var.vpc_subnets,5)
  map_public_ip_on_launch = false
  availability_zone       = data.aws_availability_zones.az.names[2]
  tags = {
    Name = "${var.project}-private3"
    Project = var.project
  }
  lifecycle {
    create_before_destroy = false
  }
}
```

## 7. Creating an Elastic IP for NatGateWay
```sh
resource "aws_eip" "eip" {
  vpc      = true
  tags = {
    Name = "${var.project}-eip"
    Project = var.project
  }
}
```

## 8. Creating NAT GateWay
```sh
resource "aws_nat_gateway" "nat" {
    
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.public1.id

  tags = {
    Name = "${var.project}-nat"
    Project = var.project
  }
}
```

## 9. Creating Public and Private Route Table
```sh
###################################################################
# Route Table Public
###################################################################

resource "aws_route_table" "public" {
    
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
tags = {
    Name = "${var.project}-public-rtb"
    Project = var.project
  }
}

###################################################################
# Route Table Private
###################################################################

resource "aws_route_table" "private" {
    
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }
tags = {
    Name = "${var.project}-private-rtb"
    Project = var.project
  }
}
```

## 10. Route Table Association
```sh
###################################################################
# Route Table association public route table
###################################################################

resource "aws_route_table_association" "public1" {
  subnet_id      = aws_subnet.public1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public2" {
  subnet_id      = aws_subnet.public2.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public3" {
  subnet_id      = aws_subnet.public3.id
  route_table_id = aws_route_table.public.id
}

###################################################################
# Route Table association Private route table
###################################################################

resource "aws_route_table_association" "private1" {
  subnet_id      = aws_subnet.private1.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private2" {
  subnet_id      = aws_subnet.private2.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private3" {
  subnet_id      = aws_subnet.private3.id
  route_table_id = aws_route_table.private.id
}
```

## 11. Creating Security Group
##### For Bastion server
```sh
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
```
- Allows only port 22 from anywhere.

##### For Webserver
```sh
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

```
- Allows port 80 and 443 from anywhere and port 22 from bastion server

##### For Database Server
```sh
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
```
- Allows 3360 port from webserver and 22 from bastion server

# 12. Creating a key pair
- First generate a key using the following command and enter a file in which to save the key
```sh
ssh-keygen
```
> Here, I used the file name as terraform
```sh
resource "aws_key_pair" "key" {
  key_name   = "${var.project}-key"
  public_key = file("terraform.pub")    #=====> Name of the publick key file
  tags = {
    Name = "${var.project}-key"
    Project = var.project
  }
}
```
# 13. Creating Instances
```sh
#########################################
# bastion
#########################################

resource "aws_instance" "bastion" {

  ami                          =  var.ami                            #=======> ami
  instance_type                =  var.type                           #=======> Instance type
  subnet_id                    =  aws_subnet.public2.id              #=======> Subenet where the instance should be installed
  vpc_security_group_ids       =  [ aws_security_group.bastion.id]   #=======> Adding the security gropu
  key_name                     =  aws_key_pair.key.id                #=======> Adding key pair
  tags = {
    Name = "${var.project}-bastion"
    Project = var.project
  }

}

##########################################
# webserver
##########################################

resource "aws_instance" "webserver" {

  ami                          =  var.ami
  instance_type                =  var.type
  subnet_id                    =  aws_subnet.public1.id
  vpc_security_group_ids       =  [ aws_security_group.webserver.id]
  key_name                     =  aws_key_pair.key.id
  tags = {
    Name = "${var.project}-webserver"
    Project = var.project
  }
  
}

############################################
# database
############################################

resource "aws_instance" "database" {

  ami                          =  var.ami
  instance_type                =  var.type
  subnet_id                    =  aws_subnet.private1.id
  vpc_security_group_ids       =  [ aws_security_group.database.id]
  key_name                     =  aws_key_pair.key.id
  tags = {
    Name = "${var.project}-database"
    Project = var.project
  }
 }
```

# Conclusion
Here is a simple document on how to use Terraform to build an AWS VPC
