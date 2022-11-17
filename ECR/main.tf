
#The bucket and the key place is hardcoded

provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}

# Data Blocks

data "terraform_remote_state" "demo_vpc" {
    backend = "s3"
    config = {
        bucket  = "backend-state1234"
        key     = "demo-vpc/terraform.tfstate"
        region  = "us-east-2"
    }
}

data "aws_ami" "redhat" {
  most_recent = true
  filter {
    name   = "name"
    values = ["RHEL-7.5_HVM_GA*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["309956199498"]
}


