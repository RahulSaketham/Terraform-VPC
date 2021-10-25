###################################################################
# Creating Elastic Ip for NatGateWay
###################################################################

resource "aws_eip" "eip" {
  vpc      = true
  tags = {
    Name = "${var.project}-eip"
    Project = var.project
  }
}

###################################################################
# Nat GateWay Creation
###################################################################

resource "aws_nat_gateway" "nat" {
    
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.public1.id

  tags = {
    Name = "${var.project}-nat"
    Project = var.project
  }


}
