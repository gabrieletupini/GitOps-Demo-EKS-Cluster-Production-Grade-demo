#before createing eks cluster a IAM role is necessary

resource "aws_iam_role" "dev" {
  name = "eks-cluster-dev"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17"
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

#then we attach the required IAM policy with the eks-cluster-dev IAM role


resource "aws_iam_role_policy_attachment" "dev-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.dev.name
}



#now the EKS resource call



resource "aws_eks_cluster" "dev" {
  name     = "dev"
  role_arn = aws_iam_role.dev.arn

  vpc_config {
    subnet_ids = [
      aws_subnet.private-us-east-1a.id,
      aws_subnet.private-us-east-1b.id,
      aws_subnet.public-us-east-1a.id,
      aws_subnet.public-us-east-1b.id
   ]

  depends_on = [aws_iam_role_policy_attachment.dev-AmazonEKSClusterPolicy] 
  #until the IAM role is ready, EKS cluster will not be created

}


