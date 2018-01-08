#################################################
# AWS Region
variable "region" {
	default = "us-east-2"
}
variable "availZones" {
	type = "list"
	default = ["us-east-2a", "us-east-2b", "us-east-2c"]
}

#################################################
# Project naming

variable "projectName" {
	default = "myproject"
}
variable "stageName" {
	default = "dev"
}
variable "costCenter" {
	default = "1234.5678"
}

#################################################
# web/app servers

# EC2 Instances
variable "webAmi" {
	default = "ami-e97c548c" # AWS 2 for us-east-2
}
variable "webInstanceType" {
	default = "t2.micro"
}
variable "publicSshKey" {
	default = "./ssh/id_rsa.pub"
}

# Autoscaling Group
variable "tgtGrpDesiredSize" {
	default = "2"
}
variable "tgtGrpMinSize" {
	default = "2"
}
variable "tgtGrpMaxSize" {
	default = "2"
}
variable "healthCheckGracePeriod" {
	#default = "300" # a sane number
	default = "90" # faster for testing
}

###############################################################
# Network Vars

variable "vpcCidr" {
	default = "10.0.0.0/16"
}
variable "publicCidrs" {
	type = "list"
	default = ["10.0.0.0/24", "10.0.1.0/24", "10.0.2.0/24"]
}
variable "appCidrs" {
	type = "list"
	default = ["10.0.10.0/24", "10.0.11.0/24", "10.0.12.0/24"]
}
variable "databaseCidrs" {
	type = "list"
	default = ["10.0.20.0/24", "10.0.21.0/24", "10.0.22.0/24"]
}

###############################################################
# Vault Server

variable "vaultAmi" {
	default = "ami-e97c548c" # standard AWS Linux 2
}
variable "vaultInstanceType" {
	default = "t2.micro"
}

###############################################################
# Database 

variable "dbRootUser" {
	default = "root"
}
variable "dbRootPass" {
	#default = "password"
}
variable "dbInstanceCount" {
	default = "2"
}
variable "dbInstanceType" {
	default = "db.t2.small"
}
variable "dbBackupRetention" {
	default = "7"
}
