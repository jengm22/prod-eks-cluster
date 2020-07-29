resource "aws_iam_role" "eks-cluster" {
  name = "InterviewStartingPermissions"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "eks-cluster-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks-cluster.name
}

resource "aws_iam_role_policy_attachment" "eks-cluster-AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.eks-cluster.name
}

resource "aws_eks_cluster" "eks-cluster" {
  name                      = "eks_cluster_mahu"
  version                   = "${var.eks_version}"
  role_arn                  = aws_iam_role.eks-cluster.arn
  enabled_cluster_log_types = ["api", "audit", "scheduler", "controllerManager"]

  vpc_config {
    security_group_ids = ["${aws_security_group.eks-cluster.id}"]
    subnet_ids         = ["${aws_subnet.eks-public.0.id}", "${aws_subnet.eks-private.1.id}"]
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks-cluster-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.eks-cluster-AmazonEKSServicePolicy,
  ]
}
