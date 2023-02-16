
#manage permission for applications that you deploy in kubernetes
#you can attach policies to k8s nodes directly (every pod with the same access to all AWS resources)
#openID provider will grant permissions based on the service account used on the pos


#certificate for the eks
data "tls_certificate" "eks" {
  url = aws_eks_cluster.prod.identity[0].oidc[0].issuer
}



#opneid provider
resource "aws_iam_openid_connect_provider" "eks" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.prod.identity[0].oidc[0].issuer
}


