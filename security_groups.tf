## Crate EKS master security group
resource "aws_security_group" "eks-cluster" {
  name        = "eks-cluster-sg"
  description = "Cluster communication with worker nodes"
  vpc_id      = "${aws_vpc.eks-sand.id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = "${
    map(
     "Name", "EKS - kubernetes master sg"
    )
  }"
}

## Required set of ports inbound / outbound

resource "aws_security_group_rule" "eks-cluster-ingress-node-https" {
  description              = "Allow pods to communicate with the cluster API Server"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.eks-cluster.id}"
  source_security_group_id = "${aws_security_group.eks-node.id}"
  to_port                  = 443
  type                     = "ingress"
}

resource "aws_security_group_rule" "eks-cluster-ingress-workstation-https" {
  cidr_blocks       = ["${local.workstation-external-cidr}"]
  description       = "Allow workstation to communicate with the cluster API Server"
  from_port         = 443
  protocol          = "tcp"
  security_group_id = "${aws_security_group.eks-cluster.id}"
  to_port           = 443
  type              = "ingress"
}

resource "aws_security_group" "eks-node" {
  name        = "eks-worker-node"
  description = "Security group for all nodes in the cluster"
  vpc_id      = aws_vpc.eks-sand.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    
     Name = "eks-worker-node-sg"
     "kubernetes.io/cluster/eks_cluster_mahu" = "shared"
    
  }
}

resource "aws_security_group_rule" "eks-node-ingress-self" {
  description              = "Allow node to communicate with each other"
  from_port                = 0
  protocol                 = "-1"
  security_group_id        = aws_security_group.eks-node.id
  source_security_group_id = aws_security_group.eks-node.id
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "eks-node-ingress-cluster" {
  description              = "Allow worker Kubelets and pods to receive communication from the cluster control plane"
  from_port                = 1025
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks-node.id
  source_security_group_id = aws_security_group.eks-cluster.id
  to_port                  = 65535
  type                     = "ingress"
}

# HPA requires 443 to be open for k8s control plane.
resource "aws_security_group_rule" "eks-node-ingress-hpa" {
  description              = "Allow HPA to receive communication from the cluster control plane"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks-node.id
  source_security_group_id = aws_security_group.eks-cluster.id
  to_port                  = 443
  type                     = "ingress"
}


