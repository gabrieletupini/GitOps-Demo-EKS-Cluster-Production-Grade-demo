provider "aws" {
  version = "~> 4.0"
  region  = "us-east-1" #region where we create VPC and EKS Clusters

}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}