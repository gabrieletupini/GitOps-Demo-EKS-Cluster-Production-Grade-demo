#single instance group for kubernetes


resource "aws_iam_role" "nodes" {
  name = "eks-node-group-nodes"

  assume_role_policy = jsonencode({ #built in tool to convert object to json
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}


resource "aws_iam_role_policy_attachment" "nodes-AmazonEKSWorkerNodePolicy" {
  policy_arn        = "arn:aws:iam:aws:policy/AmazonEKSWorkerNodePolicy"
  description       = aws_iam_role.nodes.name 
}
#grants access to EC2 and EKS

resource "aws_iam_role_policy_attachment" "nodes-AmazonEKS_CNI_Policy" {
  policy_arn        = "arn:aws:iam:aws:policy/AmazonEKS_CNI_Policy"
  role      = aws_iam_role.nodes.name 
}

resource "aws_iam_role_policy_attachment" "nodes-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn        = "arn:aws:iam:aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.nodes.name

 #allows to download docker images from ECR repository 

}


resource "aws_eks_node_group" "private-nodes" {
  cluster_name    = aws_eks_cluster.demo.name
  node_group_name = "private-nodes"
  node_role_arn   = aws_iam_role.example.arn

  subnet_ids =[
    aws_subnet.private-us-east-1a.id,
    aws_subnet.private-us-east-1b.id
 ]
  
}


