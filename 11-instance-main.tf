###############################################################################
# bastion
###############################################################################

resource "aws_instance" "bastion" {

  ami                          =  var.ami
  instance_type                =  var.type
  subnet_id                    =  aws_subnet.public2.id
  vpc_security_group_ids       =  [ aws_security_group.bastion.id]
  key_name                     =  aws_key_pair.key.id
  tags = {
    Name = "${var.project}-bastion"
    Project = var.project
  }

}


###############################################################################
# webserver
###############################################################################

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

###############################################################################
# database
###############################################################################

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
