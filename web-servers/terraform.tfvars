region                  = "eu-west-2"
project_name            = "project_name"
ccl-vpc-cidr_block      = "10.0.0.0/16"
tenancy                 = "default"
host_name               = true
web-public_cidrs        = ["10.0.1.0/24", "10.0.2.0/24"]
app-private_cidrs       = ["10.0.3.0/24", "10.0.4.0/24"]
subnet_ids              = ["web-public1", "web-public2", "app-private1", "app-private2"]
azs                     = ["eu-west-2a", "eu-west-2b", "eu-west-2c"]
ccl-rt                  = ["ccl-rt1", "ccl-rt2"]
ccl-rt-cidr_block       = "0.0.0.0/0"
ccl-sg                  = "ccl-sg"
ssh-port                = 22
http-port               = 80
port                    = 3306
protocol_type           = "tcp"
ccl-ssh-port            = "ccl-ssh-port"
ccl-http-port           = "ccl-http-port"
mysqlport               = "mysqlport"
ccl-port                = ["0.0.0.0/0"]
egress-port             = 0
egress-protocol         = -1
aws_instance-ccl-server = ["ami-084e8c05825742534", "ami-084e8c05825742534", "ami-084e8c05825742534", "ami-084e8c05825742534"]
instance_type           = "t2.micro"
ccl-ten                 = "default"
engine                  = "mysql"
engine_version          = "8.0.30"
instance_class          = "db.t3.micro"
allocated_storage       = "20"
storage_type            = "gp2"
identifier              = "ccl-db"
username                = "admin"
password                = "cloudrock"
multi_az                = false

















