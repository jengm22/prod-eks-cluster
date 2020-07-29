variable "eks-worker-ami" {
  default = "ami-0fc841be1f929d7d1"
}

variable "worker-node-instance_type" {
  default = "t2.micro"
}

variable "ssh_key_pair" {
   description = "Enter SSH keypair name that already exist in the account"
}

variable "public_subnets" {
    type    = "list"
    default = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnets" {
    type    = "list"
    default = ["10.0.3.0/24", "10.0.4.0/24"]
}

variable "aws_profile" {
  default = "eks"
}

variable "region" {
   default = "eu-west-2"
}

variable "access_key" {
 default = "############-Add your access key-###############"
}

variable "secret_key" {
 default = "############-Add your secret key-#############"
}

variable "eks_version" {
   default = "1.17"
}
