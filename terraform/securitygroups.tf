# Security group for Brutal Grounds Dedicated Server
resource "aws_security_group" "bg_sg" {
  name = "Brutal Grounds Security Group"
  description = "Security group that allows ingress game ports and SSH and all egress traffic"

  vpc_id = aws_vpc.bg_vpc.id

  ingress {
    description = "SSH access to the server"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Game server ports - Game Traffic"

    from_port = 7777
    to_port = 7777
    protocol = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Game server ports - Server Browser Query"

    from_port = 27015
    to_port = 27015
    protocol = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all traffic out of the server"

    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Brutal Grounds Security Group"
    Purpose = "brutal_grounds"
  }
}