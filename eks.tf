data "aws_iam_policy_document" "eks_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "eks_role" {
  name = "eks-cluster-role"
  assume_role_policy = data.aws_iam_policy_document.eks_assume_role.json
}

resource "aws_eks_cluster" "eks_cluster" {
  name = "devops-cluster"
  role_arn = aws_iam_role.eks_role.arn
  version = "1.27"
  vpc_config {
    subnet_ids = concat(aws_subnet.public[*].id, aws_subnet.private[*].id)
  }
  depends_on = [aws_iam_role.eks_role]
}

resource "aws_eks_node_group" "node_group" {
  cluster_name = aws_eks_cluster.eks_cluster.name
  node_role_arn = aws_iam_role.eks_role.arn
  subnet_ids = aws_subnet.private[*].id
  instance_types = [var.node_instance_type]
  scaling_config {
    desired_size = var.node_desired_size
    min_size = var.node_min_size
    max_size = var.node_max_size
  }
}
