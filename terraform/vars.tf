variable "AWS_REGION" {
  default = "eu-central-1"
}

variable "PATH_TO_PRIVATE_KEY" {
  default = "../secrets/bg_rsa"
}

variable "PATH_TO_PUBLIC_KEY" {
  default = "../secrets/bg_rsa.pub"
}

variable "INSTANCE_TYPE" {
  default = "t2.micro"
}