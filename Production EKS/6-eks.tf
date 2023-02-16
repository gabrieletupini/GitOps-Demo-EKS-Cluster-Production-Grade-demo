#before createing eks cluster a IAM role is necessary

resource "aws_iam_role" "prod" {
  name = "eks-cluster-prod"

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

#then we attach the required IAM policy with the eks-cluster-prod IAM role


resource "aws_iam_role_policy_attachment" "prod-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.prod.name
}



#now the EKS resource call



resource "aws_eks_cluster" "prod" {
  name     = "prod"
  role_arn = aws_iam_role.prod.arn

  vpc_config {
    subnet_ids = [
      aws_subnet.private-us-east-1a.id,
      aws_subnet.private-us-east-1b.id,
      aws_subnet.public-us-east-1a.id,
      aws_subnet.public-us-east-1b.id
   ]

  depends_on = [aws_iam_role_policy_attachment.prod-AmazonEKSClusterPolicy] 
  #until the IAM role is ready, EKS cluster will not be created

}


