# Route table for Brutal Grounds Dedicated Server
resource "aws_route_table" "bg_rt" {
  vpc_id = aws_vpc.bg_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.bg_gw.id
  }

  tags = {
    Name = "Brutal Grounds Route Table"
    Purpose = "brutal_grounds"
  }
}

# Route table association for Brutal Grounds Dedicated Server
resource "aws_route_table_association" "bg_rt_a" {
  subnet_id = aws_subnet.bg_sn.id
  route_table_id = aws_route_table.bg_rt.id
}