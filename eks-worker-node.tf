#### User data for worker launch

locals {
  eks-node-private-userdata = <<USERDATA
#!/bin/bash -xe
sudo /etc/eks/bootstrap.sh --apiserver-endpoint '${aws_eks_cluster.eks-cluster.endpoint}' --b64-cluster-ca '${aws_eks_cluster.eks-cluster.certificate_authority.0.data}' 'eks_cluster_mahu'
USERDATA
}

resource "aws_launch_configuration" "eks-private-lconf" {
  iam_instance_profile        = aws_iam_instance_profile.eks-node.name
  image_id                    = var.eks-worker-ami
  instance_type               = var.worker-node-instance_type
  key_name                    = var.ssh_key_pair
  security_groups             = ["${aws_security_group.eks-node.id}"]
  user_data_base64            = "${base64encode(local.eks-node-private-userdata)}"

  root_block_device {
    delete_on_termination = true
    volume_size = 30
    volume_type = "gp2"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "eks-private-asg" {
  desired_capacity     = 1
  launch_configuration = aws_launch_configuration.eks-private-lconf.id
  max_size             = 3
  min_size             = 1
  name                 = "eks-private"
  vpc_zone_identifier  = ["${aws_subnet.eks-private.0.id}"]

  tag {
    key                 = "Name"
    value               = "eks-worker-private-node"
    propagate_at_launch = true
  }

  tag {
    key                 = "kubernetes.io/cluster/eks_cluster_mahu"
    value               = "owned"
    propagate_at_launch = true
  }
}

# Creating Cloudwatch alarms for both scale up/down 

resource "aws_autoscaling_policy" "eks-cpu-policy-private" {
  name = "eks-cpu-policy-private"
  autoscaling_group_name = "${aws_autoscaling_group.eks-private-asg.name}"
  adjustment_type = "ChangeInCapacity"
  scaling_adjustment = "1"
  cooldown = "300"
  policy_type = "SimpleScaling"
}

# scaling up cloudwatch metric
resource "aws_cloudwatch_metric_alarm" "eks-cpu-alarm-private" {
  alarm_name = "eks-cpu-alarm-private"
  alarm_description = "eks-cpu-alarm-private"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods = "2"
  metric_name = "CPUUtilization"
  namespace = "AWS/EC2"
  period = "120"
  statistic = "Average"
  threshold = "80"

dimensions = {
  "AutoScalingGroupName" = "${aws_autoscaling_group.eks-private-asg.name}"
}
  actions_enabled = true
  alarm_actions = ["${aws_autoscaling_policy.eks-cpu-policy-private.arn}"]
}

# scale down policy
resource "aws_autoscaling_policy" "eks-cpu-policy-scaledown-private" {
  name = "eks-cpu-policy-scaledown-private"
  autoscaling_group_name = "${aws_autoscaling_group.eks-private-asg.name}"
  adjustment_type = "ChangeInCapacity"
  scaling_adjustment = "-1"
  cooldown = "300"
  policy_type = "SimpleScaling"
}

# scale down cloudwatch metric
resource "aws_cloudwatch_metric_alarm" "eks-cpu-alarm-scaledown-private" {
  alarm_name = "eks-cpu-alarm-scaledown-private"
  alarm_description = "eks-cpu-alarm-scaledown-private"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods = "2"
  metric_name = "CPUUtilization"
  namespace = "AWS/EC2"
  period = "120"
  statistic = "Average"
  threshold = "5"

  dimensions = {
    "AutoScalingGroupName" = "${aws_autoscaling_group.eks-private-asg.name}"
  }
  actions_enabled = true
  alarm_actions = ["${aws_autoscaling_policy.eks-cpu-policy-scaledown-private.arn}"]
}

