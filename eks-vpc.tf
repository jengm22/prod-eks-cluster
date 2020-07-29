resource "aws_vpc" "eks-sand" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "eks-sand"
  }
}

resource "aws_subnet" "eks-public" {
  count = "${length(var.public_subnets)}"

  availability_zone = "${data.aws_availability_zones.available.names[count.index]}"
  cidr_block        = "${var.public_subnets[count.index]}"
  vpc_id            = "${aws_vpc.eks-sand.id}"

  tags = {
    Name = "eks-public-subnet"
    node_group_name = "node_mahu"
    "kubernetes.io/cluster/eks_cluster_mahu" = "shared"
  }
}

resource "aws_internet_gateway" "eks-igw" {
  vpc_id = "${aws_vpc.eks-sand.id}"

  tags = {
    Name = "eks-internet-gateway"
  }
}

resource "aws_route_table" "eks-public" {
  vpc_id = "${aws_vpc.eks-sand.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.eks-igw.id}"
  }

}

resource "aws_route_table_association" "eks" {
  count = "${length(var.public_subnets)}"

  subnet_id      = "${aws_subnet.eks-public.*.id[count.index]}"
  route_table_id = "${aws_route_table.eks-public.id}"
}

resource "aws_subnet" "eks-private" {
  count = "${length(var.private_subnets)}"

  availability_zone = "${data.aws_availability_zones.available.names[count.index]}"
  cidr_block        = "${var.private_subnets[count.index]}"
  vpc_id            = "${aws_vpc.eks-sand.id}"

  tags = {
    Name = "eks-private-subnet"
    node_group_name = "node_mahu"
    "kubernetes.io/cluster/eks_cluster_mahu" = "shared"
  }
}

resource "aws_eip" "nat" {
  vpc      = true
}

resource "aws_nat_gateway" "nat_gw" {
  count = 1
  
  allocation_id = "${aws_eip.nat.id}"
  subnet_id     = "${aws_subnet.eks-public.*.id[count.index]}"  #public subnet 
  depends_on = [aws_internet_gateway.eks-igw]

  tags = {
    Name = "gw NAT"
  }
}


resource "aws_route_table" "eks-private" {
  vpc_id = "${aws_vpc.eks-sand.id}"

  tags = {
        Name = "route table for private subnets"
    }
}

resource "aws_route_table_association" "eks-private" {
  count = "${length(var.private_subnets)}"

  subnet_id      = "${aws_subnet.eks-private.*.id[count.index]}"
  route_table_id = "${aws_route_table.eks-private.id}"
}
