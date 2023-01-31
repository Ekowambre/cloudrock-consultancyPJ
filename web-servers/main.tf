terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# provider
provider "aws" {
  region = var.region
}

# infrastructure models for ccl project

module "module" {
  source                  = "../module"
  region                  = var.region
  ccl-vpc-cidr_block      = var.ccl-vpc-cidr_block
  project_name            = var.project_name
  tenancy                 = var.tenancy
  host_name               = var.host_name
  web-public_cidrs        = var.web-public_cidrs
  app-private_cidrs       = var.app-private_cidrs
  subnet_ids              = var.subnet_ids
  azs                     = var.azs
  ccl-rt                  = var.ccl-rt
  ccl-rt-cidr_block       = var.ccl-rt-cidr_block
  ccl-sg                  = var.ccl-sg
  ccl-ssh-port            = var.ccl-ssh-port
  ssh-port                = var.ssh-port
  ccl-http-port           = var.ccl-http-port
  http-port               = var.http-port
  mysqlport               = var.mysqlport
  port                    = var.port
  protocol_type           = var.protocol_type
  ccl-port                = var.ccl-port
  egress-port             = var.egress-port
  egress-protocol         = var.egress-protocol
  aws_instance-ccl-server = var.aws_instance-ccl-server
  instance_type           = var.instance_type
  ccl-ten                 = var.ccl-ten
  engine                  = var.engine
  engine_version          = var.engine_version
  instance_class          = var.instance_class
  allocated_storage       = var.allocated_storage
  storage_type            = var.storage_type
  identifier              = var.identifier
  username                = var.username
  password                = var.password
  multi_az                = var.multi_az
}
