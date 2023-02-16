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



#group resource is to configure your Kubernetes workers, lots of options
resource "aws_eks_node_group" "private-nodes" {
  cluster_name    = aws_eks_cluster.demo.name #we associate here this group with EKS cluster
  node_group_name = "private-nodes"
  node_role_arn   = aws_iam_role.nodes.arn

  subnet_ids =[ #subnets where we are going to run our nodes
    aws_subnet.private-us-east-1a.id, #nodes with public IPs just replace this IDs with public subnets
    aws_subnet.private-us-east-1b.id
 ]

 capacity_type = "ON_DEMAND" #spot instances are cheaper but can be taken away
 instance_types = ["t3.small"]

 scaling_config {
    desired_size = 3
    max_size     = 5
    min_size     = 0
    #github code for cluster EKS autoscaler needed for the above parameters to take effect

 update_config = {
    max_unavailable = 1
 }

 labels = {
    role = "general"
    #this is label we can use to instruct k8s scheduler to use a particular node group by nodeAffinty or nodeSelector
 

 # taint {
 #   key    = "team"
 #   value  = "devops"
 #   effect = "NO_SCHEDULE"
 # }
#a node that can repel a set of pods with this taint policies


 # launch_template {
 #   name    = aws_launch_template.eks-with-disks.name
 #   version = aws_launch_template.eks-with-disks.latest_version
 # }
 # used for adding additional disks to our workers




depends_on = [
    aws_iam_role_policy_attachment.nodes-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.nodes-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.nodes-AmazonEC2ContainerRegistryReadOnly,
  ]
}

# resource "aws_launch_template" "eks-with-disks" {
#   name = "eks-with-disks"

#   key_name = "local-provisioner"

#   block_device_mappings {
#     device_name = "/dev/xvdb"

#     ebs {
#       volume_size = 50 #example adding 50 gb of disk to each node
#       volume_type = "gp2"
#     }
#   }
# }
# 


}






