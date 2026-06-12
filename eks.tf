resource "aws_eks_cluster" "eks" {
  name     = var.eks_name
  role_arn = aws_iam_role.eks_cluster_role.arn
  version  = var.eks_version

  vpc_config {
    subnet_ids              = concat(values(aws_subnet.public)[*].id, aws_subnet.hudai_private_subnet[*].id)
    endpoint_public_access  = true
    endpoint_private_access = true
  }

  tags = merge(local.common_tags, {
    Name = var.eks_name
  })

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy
  ]
}

resource "aws_eks_node_group" "public_nodes" {
  cluster_name    = aws_eks_cluster.eks.name
  node_group_name = "${var.eks_name}-public-node-group"
  node_role_arn   = aws_iam_role.eks_node_role.arn

  subnet_ids = values(aws_subnet.public)[*].id

  capacity_type  = "ON_DEMAND"
  instance_types = var.node_instance_types
  disk_size      = var.node_disk_size

  scaling_config {
    desired_size = var.node_desired_size
    min_size     = var.node_min_size
    max_size     = var.node_max_size
  }

  update_config {
    max_unavailable = 1
  }

  labels = {
    env = var.environment
  }

  tags = merge(local.common_tags, {
    Name = "${var.eks_name}-public-node-group"
  })

  depends_on = [
    aws_iam_role_policy_attachment.eks_worker_node_policy,
    aws_iam_role_policy_attachment.eks_cni_policy,
    aws_iam_role_policy_attachment.eks_ecr_readonly,
    aws_iam_role_policy_attachment.eks_ssm
  ]
}

resource "aws_eks_addon" "vpc_cni" {
  cluster_name = aws_eks_cluster.eks.name
  addon_name   = "vpc-cni"

  depends_on = [aws_eks_node_group.public_nodes]
}

resource "aws_eks_addon" "coredns" {
  cluster_name = aws_eks_cluster.eks.name
  addon_name   = "coredns"

  depends_on = [aws_eks_node_group.public_nodes]
}

resource "aws_eks_addon" "kube_proxy" {
  cluster_name = aws_eks_cluster.eks.name
  addon_name   = "kube-proxy"

  depends_on = [aws_eks_node_group.public_nodes]
}