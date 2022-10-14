# VPC for Brutal Grounds Dedicated Server
resource "aws_vpc" "bg_vpc" {
  cidr_block = "10.0.0.0/24"

  # default stuff but lets be explicit
  instance_tenancy = "default"
  enable_dns_support = "true"
  enable_dns_hostnames = "false"

  tags = {
    Name = "Brutal Grounds VPC"
    Purpose = "brutal_grounds"
  }
}