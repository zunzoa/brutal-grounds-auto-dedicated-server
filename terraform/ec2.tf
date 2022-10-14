# AMI lookup - latest Ubuntu 22.04
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name = "architecture"
    values = ["x86_64"]
  }
  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

# EC2 instance -> Brutal Grounds Dedicated Server
resource "aws_instance" "bg_ec2" {
  ami = data.aws_ami.ubuntu.id

  instance_type = var.INSTANCE_TYPE

  subnet_id = aws_subnet.bg_sn.id

  vpc_security_group_ids = [
    aws_security_group.bg_sg.id
  ]

  key_name = aws_key_pair.bg_keypair.key_name

  user_data = file("cloud-init.yaml")

  tags = {
    Name = "Brutal Grounds Dedicated Server EC2 Instance"
    Purpose = "brutal_grounds"
  }
}

output "ip" {
  value = aws_instance.bg_ec2.public_ip
}