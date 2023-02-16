#we need two public and two private subnets in different availabilty zones
#this is an EKS requirement

resource "aws_subnet" "private-us-east-1a" {
  vpc_id           = aws_vpc.main.id
  cidr_block       = "10.0.0.0/19"
  availabilty_zone = "us-east-1a"

  tags = {
    "Name" = "private-us-east-1a" 
    "kubernetes.io/role/internal-elb" = "1" #required for kubernetes to discover subnets where private load balancers will be created
    "kubernetes.io/cluster/qa"      = "owned"
  }
}

resource "aws_subnet" "private-us-east-1b" {
  vpc_id           = aws_vpc.main.id
  cidr_block       = "10.0.32.0/19"
  availabilty_zone = "us-east-1b"

  tags = {
    "Name" = "private-us-east-1a" 
    "kubernetes.io/role/internal-elb" = "1" #required for kubernetes to discover subnets where private load balancers will be created
    "kubernetes.io/cluster/qa"      = "owned"
  }
}


#now the public ones


resource "aws_subnet" "public-us-east-1a" {
  vpc_id           = aws_vpc.main.id
  cidr_block       = "10.0.64.0/19"
  availabilty_zone = "us-east-1a"
  map_public_ip_on_launch = true


  tags = {
    "Name" = "public-us-east-1a" 
    "kubernetes.io/role/internal-elb" = "1" #required for kubernetes to discover subnets create public load balancers will be created
    "kubernetes.io/cluster/qa"      = "owned"
  }
}

resource "aws_subnet" "public-us-east-1b" {
  vpc_id           = aws_vpc.main.id
  cidr_block       = "10.0.96.0/19"
  availabilty_zone = "us-east-1b"
  map_public_ip_on_launch = true


  tags = {
    "Name" = "public-us-east-1b" 
    "kubernetes.io/role/internal-elb" = "1" #required for kubernetes to discover subnets create public load balancers will be created
    "kubernetes.io/cluster/qa"      = "owned"
  }
}