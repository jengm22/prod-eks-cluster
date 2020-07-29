# # create aws vpn gateway for EKS VPC
resource "aws_vpn_gateway" "vpn_gw" {
  vpc_id = aws_vpc.eks-sand.id

  tags = {
     Name = "eks aws vpn gateway"
  }
}
