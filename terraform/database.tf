# database.tf

# Create the database cluster
resource "aws_rds_cluster" "rds_cluster" {
	engine					= "aurora"
	cluster_identifier_prefix = "${var.projectName}-${var.stageName}-rds-cluster-"
	availability_zones      = ["${var.availZones}"]
	database_name           = "${var.projectName}${var.stageName}db"
	master_username         = "${var.dbRootUser}"
	master_password         = "${var.dbRootPass}"
	backup_retention_period = "${var.dbBackupRetention}"
	vpc_security_group_ids	= ["${aws_security_group.db_sg.id}"]
	db_subnet_group_name	= "${aws_db_subnet_group.rds_subnet_group.name}"
	storage_encrypted		= "true"
	db_cluster_parameter_group_name = "${aws_rds_cluster_parameter_group.rds_pg.name}"
	tags {
        Project     = "${var.projectName}"
        Stage       = "${var.stageName}"
        CostCenter  = "${var.costCenter}"
    }
}

resource "aws_rds_cluster_instance" "rds_cluster_inst" {
	count              = "${var.dbInstanceCount}"
	identifier         = "${var.projectName}-${var.stageName}-rds-${count.index}"
	cluster_identifier = "${aws_rds_cluster.rds_cluster.id}"
	instance_class     = "${var.dbInstanceType}"
	tags {
        Project     = "${var.projectName}"
        Stage       = "${var.stageName}"
        CostCenter  = "${var.costCenter}"
    }

}

resource "aws_db_subnet_group" "rds_subnet_group" {
	name       = "${var.projectName}-${var.stageName}-rds-subnet-grp"
	subnet_ids = ["${aws_subnet.database_subnet.*.id}"]
	tags {
		Name		= "${var.projectName}-${var.stageName}-rds-subnet_grp"
        Project     = "${var.projectName}"
        Stage       = "${var.stageName}"
        CostCenter  = "${var.costCenter}"
	}
}

# Parameter Group
resource "aws_rds_cluster_parameter_group" "rds_pg" {
	name   = "${var.projectName}-${var.stageName}-rds-pg"
	family = "aurora5.6"
	#parameter {
	#	name  = "character_set_server"
	#	value = "utf8"
	#}
}


###########################################################
# Database Security Group

# Security Group that allows db access from app layer
resource "aws_security_group" "db_sg" {
    name = "${var.projectName}-${var.stageName}-db-sg"
    vpc_id = "${aws_vpc.vpc.id}"
    tags {
        Name        = "${var.projectName}-${var.stageName}-db-sg"
        Project     = "${var.projectName}",
        Stage       = "${var.stageName}"
        CostCenter  = "${var.costCenter}"
    }
}

# Rule to allow db servers to talk via port 3306 to app server subnets
resource "aws_security_group_rule" "db_sg_3306in" {
    type            = "ingress"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    cidr_blocks     = ["${var.appCidrs}"]
    security_group_id = "${aws_security_group.db_sg.id}"
}

# Rule to allow db servers to talk out to the world
resource "aws_security_group_rule" "db_sg_ALLout" {
    type            = "egress"
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
    security_group_id = "${aws_security_group.db_sg.id}"
}

# Note: if bastion.tf host is defined, the rule to allow it's ssh access is
#       in the bastion.tf file
