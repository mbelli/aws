provider "aws" {
  region = var.region
}

data "aws_availability_zones" "available" {
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.8.1"

  name = "thierry-vpc"

  cidr = "10.0.0.0/16"
  azs  = slice(data.aws_availability_zones.available.names, 0, 3)

  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.8.5"

  cluster_name    = "thierry-eks"
  cluster_version = "1.33"

  cluster_endpoint_public_access           = false
  enable_cluster_creator_admin_permissions = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  eks_managed_node_group_defaults = {
    ami_type = "AL2_x86_64"

  }

  eks_managed_node_groups = {
    one = {
      name = "node-group-1"

      instance_types = ["t1.micro"]

      min_size     = 1
      max_size     = 3
      desired_size = 2
    }

    two = {
      name = "node-group-2"

      instance_types = ["t1.micro"]

      min_size     = 1
      max_size     = 2
      desired_size = 1
    }
  }
}

module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "5.8.0"

  for_each = toset(["one", "two", "three"])

  name = "instance-${each.key}"

  instance_type          = "t1.micro"
  key_name               = "user1"
  monitoring             = true
  vpc_security_group_ids = ["sg-12345678"]
  subnet_id              = "subnet-eddcdzz4"
  root_block_device = [
    {
      volume_type = "gp2"
      volume_size = 10
      encrypted = true
    },
  ]

  ebs_block_device = [
    {
      device_name = "/dev/sdg"
      volume_size = 5
      volume_type = "gp2"
      delete_on_termination = false
      encrypted = true
    }
  ]

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

#tfsec:ignore:aws-s3-enable-bucket-logging
#resource "aws_s3_bucket" "thierry" {
#  bucket = "thierry-19"
#}

#resource "aws_s3_bucket_ownership_controls" "thierry" {
#  bucket = aws_s3_bucket.thierry.id
#  rule {
#    object_ownership = "BucketOwnerPreferred"
#  }
#}

#resource "aws_s3_bucket_acl" "thierry" {
#  depends_on = [aws_s3_bucket_ownership_controls.thierry]

#  bucket = aws_s3_bucket.thierry.id
#  acl    = "private"
#}

#resource "aws_s3_bucket_public_access_block" "thierry" {
#  bucket = aws_s3_bucket.thierry.id

#  block_public_acls       = true
#  block_public_policy     = true
#  ignore_public_acls      = true
#  restrict_public_buckets = true
#}

#resource "aws_s3_bucket_versioning" "versioning_thierry" {
#  bucket = aws_s3_bucket.thierry.id
#  versioning_configuration {
#    status = "Enabled"
#  }
#}

#resource "aws_kms_key" "mykey" {
#  description             = "This key is used to encrypt bucket objects"
#  enable_key_rotation     = true
#  deletion_window_in_days = 7
#}

#resource "aws_s3_bucket_server_side_encryption_configuration" "thierry" {
#  bucket = aws_s3_bucket.thierry.id

#  rule {
#    apply_server_side_encryption_by_default {
#      kms_master_key_id = aws_kms_key.mykey.arn
#      sse_algorithm     = "aws:kms"
#    }
#  }
#}