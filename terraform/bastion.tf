# bastion.tf

###############################################################
# Queries

# get the default vpc for this account/region
data "aws_vpc" "default_vpc" {
  default = true
}

# get a list of subnets in the default vpc
data "aws_subnet_ids" "default_subnets" {
  vpc_id = "${data.aws_vpc.default_vpc.id}"
}

#################################################
# Bastion Host

# Create a bastion host living in the first subnet of the default vpc
resource "aws_instance" "bastion" {
   ami             = "${var.webAmi}"
   instance_type   = "t2.micro"
   subnet_id       = "${data.aws_subnet_ids.default_subnets.ids[0]}"
   key_name        = "${aws_key_pair.public_key.key_name}"
   vpc_security_group_ids = ["${aws_security_group.bastion_sg.id}"]

   tags {
       Name        = "${var.projectName}-${var.stageName}-bastion"
       Project     = "${var.projectName}",
       Stage       = "${var.stageName}"
       CostCenter  = "${var.costCenter}"
   }
}

# Security Group that allows ssh access to the bastion host
resource "aws_security_group" "bastion_sg" {
   name            = "${var.projectName}-${var.stageName}-bastion-sg"
   vpc_id          = "${data.aws_vpc.default_vpc.id}"
   ingress {
       from_port   = 22
       to_port     = 22
       protocol    = "tcp"
       cidr_blocks = ["0.0.0.0/0"]
   }
    egress {
       from_port   = 0
       to_port     = 0
       protocol    = "-1"
       cidr_blocks = ["0.0.0.0/0"]
    }
   tags {
       Name        = "${var.projectName}-${var.stageName}-bastion-sg"
       Project     = "${var.projectName}",
       Stage       = "${var.stageName}"
       CostCenter  = "${var.costCenter}"
   }
}

# Add rule to the app_sg security group to allow the bastion host to ssh in
resource "aws_security_group_rule" "web_sg_Bastion22in" {
    type            = "ingress"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    cidr_blocks = ["${aws_instance.bastion.private_ip}/32"]
    security_group_id = "${aws_security_group.app_sg.id}"
}

# Add rule to the vault_sg security group to allow the bastion host to ssh in
resource "aws_security_group_rule" "vault_sg_Bastion22in" {
    type            = "ingress"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    cidr_blocks = ["${aws_instance.bastion.private_ip}/32"]
    security_group_id = "${aws_security_group.vault_sg.id}"
}

# Add rule to the db_sg security group to allow the bastion host to mysql in
resource "aws_security_group_rule" "db_sg_Bastion3306in" {
    type            = "ingress"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    cidr_blocks = ["${aws_instance.bastion.private_ip}/32"]
    security_group_id = "${aws_security_group.db_sg.id}"
}
