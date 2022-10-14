resource "aws_key_pair" "bg_keypair" {
  key_name = "Brutal Grounds Key Pair"

  public_key = file(var.PATH_TO_PUBLIC_KEY)

  tags = {
    Name = "Brutal Grounds Key Pair"
    Purpose = "brutal_grounds"
  }
}