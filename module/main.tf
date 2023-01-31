/* Create a complete VPC in eu-west-2 */
resource "aws_vpc" "ccl-vpc" {
  cidr_block           = var.ccl-vpc-cidr_block
  enable_dns_hostnames = var.host_name
  instance_tenancy     = var.tenancy

  tags = {
    Name = "${var.project_name}"
  }
}
 
# use data source to get all availability zones in the region
data "aws_availability_zones" "azs" {}

# Allowing internet access into our ccl-project vpc
resource "aws_internet_gateway" "ccl-igw" {
  vpc_id = aws_vpc.ccl-vpc.id

  tags = {
    Name = "${var.project_name}-ccl-igw"
  }
}

# creating 2 web-public subnets by using the element and count index functions 
resource "aws_subnet" "web-public" {
  count             = length(var.web-public_cidrs)
  vpc_id            = aws_vpc.ccl-vpc.id
  cidr_block        = element(var.web-public_cidrs, count.index)
  availability_zone = element(var.azs, count.index)

  tags = {
    Name = "web public ${count.index + 1}"
  }
}

# creating 2 app-private subnets by using the element and count index functions 
resource "aws_subnet" "app-private" {
  count             = length(var.app-private_cidrs)
  vpc_id            = aws_vpc.ccl-vpc.id
  cidr_block        = element(var.app-private_cidrs, count.index)
  availability_zone = element(var.azs, count.index)

  tags = {
    Name = "app private ${count.index + 1}"
  }
}

/* Creating route table for both the private and public subnets 
using the count index function */
resource "aws_route_table" "ccl-rt" {
  count  = length(var.ccl-rt)
  vpc_id = aws_vpc.ccl-vpc.id

  tags = {
    Name = "ccl-rt ${count.index + 1}"
  }
}

# creating the route table association having the count index in mind, we 
# associate it with the count 1 which will be ccl-rt1 
resource "aws_route_table_association" "ccl-rtpub" {
  count          = length(var.web-public_cidrs)
  subnet_id      = element(aws_subnet.web-public[*].id, count.index)
  route_table_id = aws_route_table.ccl-rt[0].id

  depends_on = [
    aws_subnet.web-public
  ]
}

resource "aws_route_table_association" "ccl-rtpriv" {
  count          = length(var.app-private_cidrs)
  subnet_id      = element(aws_subnet.app-private[*].id, count.index)
  route_table_id = aws_route_table.ccl-rt[1].id

  depends_on = [
    aws_subnet.app-private
  ]
}

# Internet gateway attachment (route)
resource "aws_route" "ccl-igwatt" {
  route_table_id         = aws_route_table.ccl-rt[0].id
  destination_cidr_block = var.ccl-rt-cidr_block
  gateway_id             = aws_internet_gateway.ccl-igw.id
}

# elastic ip address
resource "aws_eip" "ccl-eipa" {
  vpc = true
}

# NAT gateway components
resource "aws_nat_gateway" "ccl-nat" {
  allocation_id = aws_eip.ccl-eipa.id
  #count         = length(var.web-public_cidrs)
  subnet_id     = aws_subnet.web-public[1].id

  depends_on = [
    aws_subnet.web-public
  ]

  tags = {
    Name = "ccl-nat"
  }
}

# Nat gateway attachment (route)
resource "aws_route" "ccl-nat-asso" {
  route_table_id         = aws_route_table.ccl-rt[1].id
  destination_cidr_block = var.ccl-rt-cidr_block
  gateway_id             = aws_nat_gateway.ccl-nat.id
}

/* Create security groups exposing to port 80 and 22. For each security group, you add rules 
that control the traffic based on protocols and port numbers. There are separate sets of 
 rules for inbound traffic and outbound traffic */
# create Security group for the ec2 instance
resource "aws_security_group" "ccl-sg" {
  description = var.ccl-sg
  vpc_id      = aws_vpc.ccl-vpc.id

  ingress {
    description = var.ccl-ssh-port
    from_port   = var.ssh-port
    to_port     = var.ssh-port
    protocol    = var.protocol_type
    cidr_blocks = var.ccl-port
  }

  ingress {
    description = var.ccl-http-port
    from_port   = var.http-port
    to_port     = var.http-port
    protocol    = var.protocol_type
    cidr_blocks = var.ccl-port
  }

  # for db connection
  ingress {
    description = var.mysqlport
    from_port   = var.port
    to_port     = var.port
    protocol    = var.protocol_type
    cidr_blocks = var.ccl-port
  }

  egress {
    from_port   = var.egress-port
    to_port     = var.egress-port
    protocol    = var.egress-protocol
    cidr_blocks = var.ccl-port
  }
}

# 2 (t2.micro) Servers to be placed in public and 2 to be in the private subnets
# deploying 2 ec2 instances each
resource "aws_instance" "ccl-server" {
  #count                  = length(var.ccl-server)
  count                  = 2
  ami                    = element(var.aws_instance-ccl-server, count.index)
  instance_type          = var.instance_type
  vpc_security_group_ids = ["${aws_security_group.ccl-sg.id}"]
  tenancy                = var.ccl-ten
  subnet_id              = element(aws_subnet.app-private[*].id, count.index)


  tags = {
    Name = "ccl-server"
  }
}

resource "aws_instance" "ccl-servers" {
  #count                  = length(var.ccl-server)
  count                  = 2
  ami                    = element(var.aws_instance-ccl-server, count.index)
  instance_type          = var.instance_type
  vpc_security_group_ids = ["${aws_security_group.ccl-sg.id}"]
  tenancy                = var.ccl-ten
  subnet_id              = element(aws_subnet.web-public[*].id, count.index)


  tags = {
    Name = "ccl-servers"
  }
}

resource "aws_db_instance" "ccl-projectrds" {
  engine              = var.engine
  engine_version      = var.engine_version
  instance_class      = var.instance_class
  allocated_storage   = var.allocated_storage
  storage_type        = var.storage_type
  identifier          = var.identifier
  username            = var.username
  password            = var.password
  multi_az            = var.multi_az
  port                = var.port
  skip_final_snapshot = true

  tags = {
    Name = "ccl-rds-db"
  }
}


/* 1. https://www.terraform.io/docs/providers/aws/r/db_instance.html = source

   2. Amazon RDS will default to a recent release if no version is specified.
   https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_MySQL.html#MySQL.Concepts.VersionMgmt 

   3. The DB instance class determines the computation and memory capacity of an Amazon RDS DB instance.
    it is recomended to only use db.t2 instance classes for development and test servers, 
    or other non-production servers.
   https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Concepts.DBInstanceClass.html 

    4. General purpose SSD is from 20GB to 32 TiB. for this project i will choose 20 GB

    5. https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_Limits.html#RDS_Limits.Constraints
     paremeter for db identifier must be in lower case 
    and must not end with a hyphen */

# https://www.terraform.io/docs/providers/aws/r/security_group.html