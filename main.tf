resource "aws_eks_cluster" "pankaj-cluster" {
  name     = "pankaj-cluster"
  role_arn = aws_iam_role.example.arn

  vpc_config {
    subnet_ids = [
      aws_subnet.our-public-subnet.id,
      aws_subnet.our-public-subnet2.id
    ]
  }

  depends_on = [
    aws_iam_role_policy_attachment.example-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.example-AmazonEKSVPCResourceController,
  ]
}

output "endpoint" {
  value = aws_eks_cluster.pankaj-cluster.endpoint
}

output "kubeconfig-certificate-authority-data" {
  value = aws_eks_cluster.pankaj-cluster.certificate_authority[0].data
}

resource "aws_eks_node_group" "node-grp" {
  cluster_name    = aws_eks_cluster.pankaj-cluster.name
  node_group_name = "pc-node-group"
  node_role_arn   = aws_iam_role.worker.arn
  subnet_ids      = [
    aws_subnet.our-public-subnet.id,
    aws_subnet.our-public-subnet2.id
  ]
  capacity_type   = "ON_DEMAND"
  disk_size       = 20
  instance_types  = ["t2.medium"]
  labels          = { env = "dev" }

  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 1
  }

  update_config {
    max_unavailable = 1
  }

  depends_on = [
    aws_eks_cluster.pankaj-cluster,
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly
  ]
}
