# Internet Gateway for Brutal Grounds Dedicated Server
resource "aws_internet_gateway" "bg_gw" {
  vpc_id = aws_vpc.bg_vpc.id

  tags = {
    Name = "Brutal Grounds Gateway"
    Purpose = "brutal_grounds"
  }
}