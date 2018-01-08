# vault.tf - creates a vault server in the app layer subnet


#################################################
# Vault Host

# Create a vault host living one of the app subnets
resource "aws_instance" "vault" {
	ami             = "${var.vaultAmi}"
	instance_type   = "t2.micro"
	# I dont really care which app subnet it lands in, just trying to match diagrams
	# TODO: should not hard set subnet instance to 2, its brittle... 
	#       use something like length(aws_subnet.app_subnet)-1 instead...
	#subnet_id       	= "${element(aws_subnet.app_subnet.*.id,length(aws_subnet.app_subnet)-1)}"
	subnet_id       	= "${element(aws_subnet.app_subnet.*.id,2)}"
	key_name        	= "${aws_key_pair.public_key.key_name}"
	iam_instance_profile	= "${aws_iam_instance_profile.vault_iam_profile.name}"
	vpc_security_group_ids	= ["${aws_security_group.vault_sg.id}"]
	user_data		= "${file("vaultuserdata.sh")}"

	tags {
		Name        = "${var.projectName}-${var.stageName}-vault"
		Project     = "${var.projectName}",
		Stage       = "${var.stageName}"
		CostCenter  = "${var.costCenter}"
	}
}

#################################################
# Vault Security Group

# Create the Vault Security Group
resource "aws_security_group" "vault_sg" {
    name = "${var.projectName}-${var.stageName}-vault-sg"
    vpc_id = "${aws_vpc.vpc.id}"
    tags {
        Name        = "${var.projectName}-${var.stageName}-vault-sg"
        Project     = "${var.projectName}",
        Stage       = "${var.stageName}"
        CostCenter  = "${var.costCenter}"
    }
}

# Rule to allow app servers to talk to us via port 80 
resource "aws_security_group_rule" "vault_sg_80in" {
    type            = "ingress"
    from_port       = 8200
    to_port         = 8200
    protocol        = "tcp"
    cidr_blocks     = ["${var.appCidrs}"]
    security_group_id = "${aws_security_group.vault_sg.id}"
}

# Rule to allow vault server to talk out to the world
resource "aws_security_group_rule" "vault_sg_ALLout" {
    type            = "egress"
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
    security_group_id = "${aws_security_group.vault_sg.id}"
}

# Note: if bastion.tf host is defined, the rule to allow it's ssh access is
#       in the bastion.tf file

#################################################
# Vault IAM role

resource "aws_iam_role" "vault_iam_role" {
    name = "${var.projectName}-${var.stageName}-vault-role"
	path = "/"
	description = "Role to allow vault server to authenicate EC2 instances"
	assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
	    {   
            "Sid":"",
            "Effect":"Allow",
            "Principal":{"Service":"ec2.amazonaws.com"},
            "Action":"sts:AssumeRole"
		}
	]
}
EOF
}

# Attach a policy to the vault role that allows it to use the AWS EC2 auth module
resource "aws_iam_role_policy" "vault_policy" {
    name = "${var.projectName}-${var.stageName}-vault-policy"
    role = "${aws_iam_role.vault_iam_role.id}"
    policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:DescribeInstances",
        "iam:GetInstanceProfile",
        "iam:GetUser",
        "iam:GetRole"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

# Create an IAM instance profile that allows us to attach IAM role to EC2 instance
resource "aws_iam_instance_profile" "vault_iam_profile" {
    name = "${var.projectName}-${var.stageName}-vault-profile"
  	role = "${aws_iam_role.vault_iam_role.name}"
}
