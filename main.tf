terraform {
  required_version = ">= 1.6"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.50"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }

  backend "s3" {
    bucket         = "hudai-terraform-state"
    key            = "dev/eks/cluster.tfstate"
    region         = "ap-southeast-1"
    encrypt        = true
    dynamodb_table = "terraform-locks"
  }
}

provider "aws" {
  region = var.aws_region
}

locals {
  common_tags = {
    Environment = var.environment
    ManagedBy   = "terraform"
    Project     = var.project_name
  }

  public_subnets = {
    az1 = { cidr = var.public_subnet_cidrs_block[0], az = var.azs[0] }
    az2 = { cidr = var.public_subnet_cidrs_block[1], az = var.azs[1] }
    az3 = { cidr = var.public_subnet_cidrs_block[2], az = var.azs[2] }
  }
}

resource "aws_vpc" "eks_vpc" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(local.common_tags, {
    Name = var.vpc_name
  })
}

resource "aws_subnet" "public" {
  for_each = local.public_subnets

  vpc_id                  = aws_vpc.eks_vpc.id
  cidr_block              = each.value.cidr
  availability_zone       = each.value.az
  map_public_ip_on_launch = true

  tags = merge(local.common_tags, {
    Name                                    = "hudai-public-subnet-${each.key}-${each.value.az}"
    Tier                                    = "public"
    "kubernetes.io/role/elb"                = "1"
    "kubernetes.io/cluster/${var.eks_name}" = "shared"
  })
}

resource "aws_subnet" "hudai_private_subnet" {
  count             = length(var.private_subnet_cidrs_block)
  vpc_id            = aws_vpc.eks_vpc.id
  cidr_block        = var.private_subnet_cidrs_block[count.index]
  availability_zone = var.azs[count.index]

  tags = merge(local.common_tags, {
    Name                                    = "hudai-private-subnet-${count.index + 1}-${var.azs[count.index]}"
    Tier                                    = "private"
    "kubernetes.io/role/internal-elb"       = "1"
    "kubernetes.io/cluster/${var.eks_name}" = "shared"
  })
}

resource "aws_internet_gateway" "hudai_igw" {
  vpc_id = aws_vpc.eks_vpc.id

  tags = merge(local.common_tags, {
    Name = var.internet_gateway_name
  })
}

resource "aws_route_table" "hudai_public_route_table" {
  vpc_id = aws_vpc.eks_vpc.id

  tags = merge(local.common_tags, {
    Name = var.public_route_table_name
  })
}

resource "aws_route_table_association" "public_subnet_association" {
  for_each = aws_subnet.public

  subnet_id      = each.value.id
  route_table_id = aws_route_table.hudai_public_route_table.id
}

resource "aws_route" "public_route" {
  route_table_id         = aws_route_table.hudai_public_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.hudai_igw.id
}

resource "aws_route_table" "hudai_private_route_table" {
  count  = length(var.azs)
  vpc_id = aws_vpc.eks_vpc.id

  tags = merge(local.common_tags, {
    Name = "hudai-rtb-private-subnet-${var.azs[count.index]}"
  })
}

resource "aws_route_table_association" "private_subnet_association" {
  count = length(var.private_subnet_cidrs_block)

  subnet_id      = aws_subnet.hudai_private_subnet[count.index].id
  route_table_id = aws_route_table.hudai_private_route_table[count.index].id
}

resource "aws_vpc_endpoint" "s3_endpoint" {
  vpc_id            = aws_vpc.eks_vpc.id
  service_name      = "com.amazonaws.${var.aws_region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [for rt in aws_route_table.hudai_private_route_table : rt.id]

  tags = merge(local.common_tags, {
    Name = var.s3_endpoint_name
  })
}